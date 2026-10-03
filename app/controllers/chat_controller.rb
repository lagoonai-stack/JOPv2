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

    # When the agent reaches Step 6 it emits the video spec in a ```json block.
    # The spec is the contract: it carries the configuration the user approved,
    # so the Remotion service no longer has to infer any of it from the prose.
    parsed_spec = extract_video_spec(response[:content])
    validated_spec = parsed_spec ? VideoSpec.build(parsed_spec) : nil

    # A spec that fails validation is our contract failing, not a question for
    # the user — repair it with the agent before anything reaches the screen.
    if validated_spec && !validated_spec.valid?
      response, parsed_spec, validated_spec = repair_invalid_spec(response, validated_spec)
    end

    generation_prompt = extract_generation_prompt(response[:content], spec: parsed_spec)
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
      # Store the generation prompt together with the spec the agent emitted, so
      # the approved dimensions/duration travel as explicit options instead of
      # being re-inferred by the Remotion service from the prose. A validated
      # spec also brings the derived timeline, whose total is computed from the
      # word counts and transition overlaps rather than taken on trust.
      # The canonical spec rides along under its own key so the render pipeline
      # keeps reading the four top-level config keys it always read.
      video_spec =
        if validated_spec&.valid?
          validated_spec.to_video_spec_column.merge("canonical" => validated_spec.to_h)
        else
          normalize_video_spec(parsed_spec)
        end

      @conversation.update!(
        generation_prompt: generation_prompt,
        video_spec: video_spec,
        video_status: "spec_ready"
      )
      Rails.logger.info(
        "[ChatController] Generation prompt detected for conversation=#{@conversation.id} " \
        "prompt_length=#{generation_prompt.length} chars " \
        "spec=#{video_spec&.except('canonical').inspect} " \
        "moments=#{validated_spec&.valid? ? validated_spec.moments.size : 'n/a'}"
      )
      if video_spec.blank?
        Rails.logger.warn(
          "[ChatController] No JSON spec block found for conversation=#{@conversation.id} — " \
          "dimensions will be inferred by the Remotion service"
        )
      end
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

    # If a prompt was just detected, move the preview panel into the header
    # dropdown so the Preview button appears immediately without a page reload.
    # This mirrors show.html.haml, which renders the panel only in the header once
    # a preview exists. Leaving the inline copy behind puts two
    # #video_preview_panel elements on the page, and the preview response then
    # replaces the hidden header copy while the visible one stays stale.
    if generation_prompt
      turbo_streams << turbo_stream.remove_all("#video_preview_panel")
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

  # The user's message is already persisted by the time this runs, so
  # api_messages already ends with it — appending it again sent the model the
  # same turn twice.
  def call_openai(_new_content = nil)
    call_openai_messages(@conversation.api_messages)
  end

  def call_openai_messages(messages)
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

  # Ask the agent to repair a spec that failed validation — once.
  #
  # The exchange never reaches the screen: neither the rejected answer nor the
  # correction request is stored as a chat message, only the repaired result.
  # A malformed spec is the contract failing, and the user has nothing to
  # decide about it.
  #
  # If the second attempt also fails, the first answer is kept: a retry that
  # still does not validate is not obviously better, and the original at least
  # matches what the user was just told. The declared dimensions are used
  # either way, so no value is left to be inferred downstream.
  #
  # @param response [Hash] the agent's first answer
  # @param spec [VideoSpec] the failed validation
  # @return [Array(Hash, Hash, VideoSpec)] response, raw spec, validated spec
  def repair_invalid_spec(response, spec)
    Rails.logger.warn(
      "[ChatController] Spec inválida para conversation=#{@conversation.id}: #{spec.errors.join(' | ')}"
    )

    # Shortening a caption is the only fix that touches text the user approved;
    # without explicit permission the agent keeps the long caption and fails again.
    caption_rule = if spec.caption_too_long?
                     <<~RULE
                       Legendas acima do limite: encurte cada uma para no máximo #{VideoSpec::MAX_CAPTION_WORDS_MINIMALISTA} palavras, preservando o sentido.
                       Artigos, preposições e conjunções contam como palavra. Isso é permitido e esperado — use a mesma legenda encurtada na prosa e no JSON.

                     RULE
                   end

    correction = <<~CORRECTION
      A spec JSON que você emitiu não passou na validação do sistema e o vídeo não pode ser gerado assim.

      Problemas encontrados:
      #{spec.error_report}

      #{caption_rule}Reenvie a mensagem completa corrigida, mantendo o bloco ```json no final.
      Corrija apenas os problemas listados — fora isso, não mude as decisões já acordadas com o usuário.
    CORRECTION

    retry_response = call_openai_messages(
      @conversation.api_messages + [
        { role: "assistant", content: response[:content] },
        { role: "user", content: correction }
      ]
    )

    retry_spec = extract_video_spec(retry_response[:content])
    validated = retry_spec ? VideoSpec.build(retry_spec) : nil

    unless validated&.valid?
      Rails.logger.error(
        "[ChatController] Spec ainda inválida após correção para conversation=#{@conversation.id}: " \
        "#{validated&.errors&.join(' | ') || 'nenhum bloco json na resposta'}"
      )
      return [response, extract_video_spec(response[:content]), spec]
    end

    Rails.logger.info(
      "[ChatController] Spec corrigida na segunda tentativa para conversation=#{@conversation.id}"
    )

    [merge_token_usage(response, retry_response), retry_spec, validated]
  end

  # The repair attempt's tokens belong to this turn, so the plan limits count it.
  def merge_token_usage(first, second)
    second.merge(
      input_tokens: first[:input_tokens].to_i + second[:input_tokens].to_i,
      output_tokens: first[:output_tokens].to_i + second[:output_tokens].to_i,
      cache_creation_input_tokens:
        first[:cache_creation_input_tokens].to_i + second[:cache_creation_input_tokens].to_i,
      cache_read_input_tokens:
        first[:cache_read_input_tokens].to_i + second[:cache_read_input_tokens].to_i
    )
  end

  # Locate the JSON spec block the agent is required to emit in Step 6.
  #
  # The contract in config/initializers/openai_agents.rb is: deliver the prose
  # direction first, then append the spec inside a ```json fence. Parsing the
  # whole message as JSON only succeeds when the message is nothing but JSON —
  # the one shape that contract does not produce. So the fence is checked first
  # and the bare-JSON form is kept as a fallback for the alternative wording at
  # the end of that prompt.
  #
  # @param content [String]
  # @return [Hash, nil] the parsed spec, or nil when the message carries none
  def extract_video_spec(content)
    return nil if content.blank?

    candidates = content.scan(/```json\s*\n?(.*?)```/m).flatten
    candidates << content.strip

    candidates.each do |candidate|
      parsed = begin
        JSON.parse(candidate)
      rescue JSON::ParserError
        next
      end

      return parsed if parsed.is_a?(Hash) && parsed.key?("moments")
    end

    nil
  end

  # Reduce the agent's spec to the configuration keys the render pipeline reads.
  # Returns nil when nothing usable is present, so callers can tell "no spec"
  # apart from "spec with no dimensions".
  #
  # @param spec [Hash, nil]
  # @return [Hash, nil]
  def normalize_video_spec(spec)
    return nil unless spec.is_a?(Hash)

    {
      "width" => spec["width"],
      "height" => spec["height"],
      "fps" => spec["fps"],
      "duration_in_frames" => spec["duration_frames"]
    }.compact.presence
  end

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
  # @param spec [Hash, nil] the spec already parsed out of this message, if any
  # @return [String, nil]
  def extract_generation_prompt(content, spec: nil)
    return nil if content.blank?

    # A valid spec block is unambiguous evidence that the agent reached Step 6.
    # Short-circuit here so the heuristics below — in particular the confirmation
    # patterns, one of which matches the bare phrase "pode gerar" anywhere in the
    # text — can never veto a message that actually carries the deliverable.
    return content.strip if spec.present?

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
