# frozen_string_literal: true

class ChatController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: %i[show create]
  before_action :require_can_access_chat, only: %i[show create]
  before_action :require_active_conversation, only: [:create]

  AGENT = ClaudeConversation::AGENT_NAME
  # Limite máximo para prevenir ataques de esgotamento de tokens e timeouts na API OpenAI.
  MAX_MESSAGE_LENGTH = 10_000

  def show
    @messages = @conversation.claude_messages.order(created_at: :asc)
    @plan = current_user.plan_config
    @usage = { tokens: current_user.tokens_used_this_period }
    @conversations = current_user.claude_conversations_for_agent(AGENT)

    # If the conversation is stuck in `previewing`, verify the token is still
    # live on the Node service. The Node stores tokens in-memory, so any restart
    # wipes them regardless of the Rails-side expiry timestamp. We do a cheap
    # HEAD-equivalent GET and reset to `spec_ready` if the token is gone, so
    # the UI shows "Generate Preview" instead of an iframe 401.
    return unless @conversation.previewing?
    return unless !@conversation.preview_token_valid? || !node_token_alive?(@conversation.preview_token)

    @conversation.update!(
      video_status: "spec_ready",
      preview_token: nil,
      preview_token_expires_at: nil
    )
  end

  def create
    unless current_user.can_send_prompt?
      if request.format.turbo_stream?
        render turbo_stream: turbo_stream.replace(
          "chat_form",
          partial: "chat/form",
          locals: { conversation: @conversation }
        ), status: :forbidden
      else
        redirect_to root_path, alert: subscription_limit_message
      end
      return
    end

    content = params[:content].to_s.strip
    if content.blank?
      if request.format.turbo_stream?
        render turbo_stream: turbo_stream.replace(
          "chat_form",
          partial: "chat/form",
          locals: { conversation: @conversation, error: t("chat.message_too_long") }
        ), status: :unprocessable_content
      else
        redirect_to chat_path, alert: t("chat.blank_message")
      end
      return
    end

    if content.length > MAX_MESSAGE_LENGTH
      if request.format.turbo_stream?
        render turbo_stream: turbo_stream.replace(
          "chat_form", partial: "chat/form", locals: { conversation: @conversation }
        ), status: :unprocessable_content
      else
        redirect_to chat_path, alert: t("chat.message_too_long")
      end
      return
    end

    @user_message = @conversation.claude_messages.create!(role: "user", content: content)
    response = call_openai(content)

    # Detect if OpenAI returned a video generation prompt in its response.
    # When the agent reaches Step 6 it provides the complete prompt for Remotion AI.
    # We extract the prompt and send it to Remotion, which will handle everything:
    # - Parse configuration (width, height, duration, fps)
    # - Generate TSX component using OpenAI
    # - Render preview and video
    generation_prompt = extract_generation_prompt(response[:content])
    display_content = if generation_prompt
                        strip_generation_prompt(response[:content])
                      else
                        response[:content]
                      end

    @assistant_message = @conversation.claude_messages.create!(
      role: "assistant",
      content: display_content,
      input_tokens: response[:input_tokens],
      output_tokens: response[:output_tokens],
      cache_creation_input_tokens: response[:cache_creation_input_tokens] || 0,
      cache_read_input_tokens: response[:cache_read_input_tokens] || 0
    )

    if generation_prompt
      # Store the generation prompt - Remotion AI will handle everything.
      # When the prompt is itself the raw JSON spec (width/height/fps/moments),
      # also normalize it into video_spec so the dimensions can be passed as
      # explicit options to the Remotion service instead of left to its own guess.
      spec = begin
        JSON.parse(generation_prompt)
      rescue JSON::ParserError
        nil
      end
      video_spec = if spec.is_a?(Hash) && spec.key?("moments")
                     {
                       "width" => spec["width"],
                       "height" => spec["height"],
                       "fps" => spec["fps"],
                       "duration_in_frames" => spec["duration_frames"]
                     }.compact
                   end

      @conversation.update!(
        generation_prompt: generation_prompt,
        video_spec: video_spec,
        video_status: "spec_ready"
      )
      Rails.logger.info(
        "[ChatController] Generation prompt detected for conversation=#{@conversation.id} " \
        "prompt_length=#{generation_prompt.length} chars"
      )
    end

    turbo_streams = [
      turbo_stream.remove("chat_optimistic_user"),
      turbo_stream.remove("chat_thinking"),
      turbo_stream.append("chat_messages", partial: "chat/message", locals: { message: @user_message }),
      turbo_stream.append("chat_messages", partial: "chat/message", locals: { message: @assistant_message }),
      turbo_stream.replace("chat_form", partial: "chat/form", locals: { conversation: @conversation }),
      turbo_stream.replace("chat_plan_usage", partial: "chat/plan_usage", locals: {
                             plan: current_user.plan_config,
                             usage: { tokens: current_user.tokens_used_this_period }
                           })
    ]

    # If a prompt was just detected, update both the preview panel and the header
    # actions so the Preview button appears immediately without a page reload.
    if generation_prompt
      turbo_streams << turbo_stream.replace(
        "video_preview_panel",
        partial: "chat/video_preview",
        locals: { conversation: @conversation, error: nil }
      )
      turbo_streams << turbo_stream.replace(
        "chat_header_actions",
        partial: "chat/header_actions",
        locals: { conversation: @conversation }
      )
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_streams, status: :ok }
      format.html { redirect_to chat_path }
    end
  end

  def finish_prompt
    conv = current_user.active_claude_conversation(AGENT)
    conv&.update!(finished_at: Time.current)
    redirect_to chat_path, notice: t("chat.finished_prompt")
  end

  private

  def set_conversation
    if params[:conversation_id].present?
      @conversation = current_user.claude_conversations.find(params[:conversation_id])
    else
      @conversation = current_user.active_claude_conversation(AGENT)
      @conversation ||= current_user.claude_conversations.create!(agent_name: AGENT)
    end
  end

  def require_can_access_chat
    return if current_user.plan_config.present?

    redirect_to root_path, alert: subscription_limit_message
  end

  def require_active_conversation
    return if @conversation&.active?

    if request.format.turbo_stream?
      head :forbidden
    else
      redirect_to chat_path, alert: t("chat.cannot_send_finished")
    end
  end

  def call_openai(new_content)
    messages = @conversation.api_messages + [{ role: "user", content: new_content }]
    OpenaiService.new.chat(agent_name: AGENT, messages: messages)
  rescue OpenaiService::MissingApiKey
    {
      content: "Error: Agent API key is not set. Contact support.",
      input_tokens: 0,
      output_tokens: 0,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: 0
    }
  rescue OpenaiService::ApiError => e
    {
      content: "API error: #{e.message}. Contact support.",
      input_tokens: 0,
      output_tokens: 0,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: 0
    }
  end

  # ---------------------------------------------------------------------------
  # Video prompt detection & content cleaning
  # ---------------------------------------------------------------------------

  # Extract the natural language generation prompt that the AI produces.
  # The agent generates a complete, detailed prompt in Step 6 that includes all
  # the information Remotion AI needs to generate the video component.
  # This prompt is typically very detailed (1000-5000+ characters).
  #
  # The prompt is identified by looking for Claude's Step 6 markers or by
  # checking for a substantial block of text that appears to be technical
  # instructions for video generation.
  #
  # @param content [String]
  # @return [String, nil]
  def extract_generation_prompt(content)
    return nil if content.blank?

    # The Step 6 deliverable can also be a raw JSON spec (width/height/fps/moments),
    # as defined in config/initializers/openai_agents.rb. This is unambiguous, so
    # detect it directly instead of relying on the prose heuristics below.
    parsed = begin
      JSON.parse(content.strip)
    rescue JSON::ParserError
      nil
    end
    return content.strip if parsed.is_a?(Hash) && parsed.key?("moments")

    # 🚨 CRITICAL: Detect confirmation questions - do NOT treat as final prompt
    # The agent asks for confirmation before generating the final prompt
    confirmation_patterns = [
      /confirma.*essa.*sequ[êe]ncia/i,
      /confirma.*proposta/i,
      /pode\s+gerar/i,
      /\d+:\s*sim.*\d+:\s*n[ãa]o/i, # "1: sim, 2: não" pattern
      /quero\s+ajustar/i,
      /confirmar.*antes/i,
      /est[áa]\s+(correto|ok|certo)/i
    ]

    # If this is a confirmation question, return nil (not ready yet)
    if confirmation_patterns.any? { |pattern| content.match?(pattern) }
      Rails.logger.info("[ChatController] Detected confirmation question - not extracting as generation prompt")
      return nil
    end

    # Claude's Step 6 output is typically the entire message when it's ready
    # Look for markers or length that indicate it's the final prompt

    # Check if this looks like a video generation prompt
    # Indicators: mentions of "momento", "frames", animation terms, detailed specs
    video_indicators = [
      /momento/i,
      /frame/i,
      /anima[çc][ãa]o/i,
      /interpola/i,
      /component/i,
      /visual/i,
      /transi[çc][ãa]o/i
    ]

    # Count how many indicators are present
    indicator_count = video_indicators.count { |pattern| content.match?(pattern) }

    # If we have multiple indicators and substantial length, it's likely the prompt
    return content.strip if indicator_count >= 3 && content.length >= 1000

    # Alternative: Look for specific Step 6 patterns from the Claude agent
    # The agent might output something like "MOMENTO 1", "BLOCO GLOBAL", etc.
    return content.strip if content.match?(/MOMENTO \d+/i) || content.match?(/BLOCO GLOBAL/i)

    nil
  end

  # Remove the generation prompt from the assistant message and replace it
  # with a friendly message asking the user to generate the preview.
  #
  # @param content [String]
  # @return [String]
  def strip_generation_prompt(content)
    # Replace the detailed prompt with a simple user-friendly message
    preview_prompt = t("chat.spec_ready_prompt")

    # If the content starts with conversational text before the technical prompt,
    # try to preserve that. Otherwise, just return the preview invitation.
    lines = content.lines
    conversational_lines = []

    # Take lines until we hit technical/detailed content
    lines.each do |line|
      break if line.match?(/MOMENTO \d+|BLOCO GLOBAL|frame|interpola/i)

      conversational_lines << line if line.strip.present?
    end

    if conversational_lines.any?
      "#{conversational_lines.join.strip}\n\n#{preview_prompt}"
    else
      preview_prompt
    end
  end

  # Check whether the preview token still exists in the Node service's
  # in-memory store. The Node loses all tokens on restart, so a token that
  # looks valid in the Rails DB may already be gone. We do a lightweight GET
  # to /preview/:token and treat anything other than a 401 as "alive".
  # Any network error is treated as "alive" (fail open) to avoid resetting
  # the state unnecessarily when the Node service is merely slow to respond.
  def node_token_alive?(token)
    return false if token.blank?

    base = ENV.fetch("REMOTION_SERVICE_URL", "http://localhost:3001")
    uri  = URI.parse("#{base}/preview/#{token}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = uri.scheme == "https"
    http.open_timeout = 3
    http.read_timeout = 5

    # We only need the status code — ask for the minimum possible response.
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Accept"] = "text/html"

    response = http.request(req)
    response.code.to_i != 401
  rescue StandardError => e
    Rails.logger.warn("[ChatController#node_token_alive?] Could not reach Node service: #{e.message}")
    true # fail open — don't reset state on transient connectivity issues
  end

  def subscription_limit_message
    if current_user.subscription_plan.blank?
      t("chat.limit_no_plan")
    elsif current_user.subscription_period_ends_at && current_user.subscription_period_ends_at < Time.current
      t("chat.limit_expired")
    else
      t("chat.limit_reached")
    end
  end
end
