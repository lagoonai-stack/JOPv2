# frozen_string_literal: true

# VideoController
#
# Handles the video preview/approval/render pipeline.
# All actions require authentication (Devise) and enforce that users can only
# access conversations that belong to them.
#
# Routes:
#   POST /conversations/:conversation_id/video/preview   → request_preview
#   POST /conversations/:conversation_id/video/approve   → approve
#   GET  /conversations/:conversation_id/video/status    → status  (polling)
#
class VideoController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :authorize_conversation!

  # ---------------------------------------------------------------------------
  # POST /conversations/:conversation_id/video/preview
  #
  # Ask the Node service to render a still preview and return a player token.
  # Responds with Turbo Stream to update the chat UI inline.
  # ---------------------------------------------------------------------------
  def request_preview
    # Only block if a full render is actively in progress — never block on
    # `previewing?` because the Node service stores tokens in-memory and loses
    # them on restart. Allowing re-requests from `previewing` lets the user
    # (or the system) obtain a fresh token without needing a page reload or
    # manual state reset.
    return respond_with_error(t("video.already_processing")) if @conversation.rendering?

    begin
      # NEW FLOW: Use AI generation with the natural language prompt
      if @conversation.generation_prompt.present?
        # Validate the generation prompt before sending
        prompt = @conversation.generation_prompt.strip

        # Safety check: ensure prompt is substantial enough
        if prompt.length < 10
          Rails.logger.error(
            "[VideoController] Generation prompt too short (#{prompt.length} chars) for conversation=#{@conversation.id}"
          )
          return respond_with_error(
            "A especificação do vídeo é muito curta. Por favor, descreva o que deseja criar com mais detalhes."
          )
        end

        Rails.logger.info(
          "[VideoController] Requesting AI generation for conversation=#{@conversation.id} " \
          "prompt_length=#{prompt.length} chars"
        )

        # Generate the component and its preview in one call.
        spec = @conversation.video_spec || {}
        result = RemotionService.generate_preview(
          @conversation,
          prompt,
          width: spec["width"],
          height: spec["height"],
          fps: spec["fps"],
          duration_in_frames: spec["duration_in_frames"]
        )

        # Store the component's source code (Node keeps it only in a tmp file)
        @conversation.update!(
          component_code: result[:component_code],
          preview_token: result[:preview_token],
          preview_token_expires_at: 7.days.from_now, # Keep preview for 7 days
          video_status: "previewing",
          detected_skills: result[:detected_skills],
          video_spec: spec.merge(
            "width" => result[:width],
            "height" => result[:height],
            "fps" => result[:fps],
            "duration_in_frames" => result[:duration_in_frames]
          ).compact
        )

        # Store preview URL in session for iframe
        session["preview_url_#{@conversation.id}"] = result[:preview_url]

        Rails.logger.info(
          "[VideoController] Preview generated for conversation=#{@conversation.id} " \
          "user=#{current_user.id} preview_token=#{result[:preview_token]}"
        )
      elsif @conversation.component_code.present?
        # Re-generate preview if component code exists
        Rails.logger.info(
          "[VideoController] Re-requesting preview for existing component"
        )
        return respond_with_error("Please generate a new video from the chat.")
      else
        return respond_with_error(t("video.no_spec"))
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "video_preview_panel",
              partial: "chat/video_preview",
              locals: { conversation: @conversation, preview_url: result[:preview_url] }
            )
          ]
        end
        format.json do
          render json: {
            preview_token: result[:preview_token],
            preview_url: result[:preview_url],
            status: "previewing"
          }
        end
        format.html { redirect_to chat_path(conversation_id: @conversation.id) }
      end
    rescue RemotionService::ConfigurationError => e
      Rails.logger.error("[VideoController] Remotion misconfigured: #{e.message}")
      respond_with_error(t("video.service_misconfigured"))
    rescue ArgumentError => e
      # Handle invalid prompt errors
      raise unless e.message.include?("Prompt") || e.message.include?("prompt")

      Rails.logger.error("[VideoController] Invalid prompt for conv=#{@conversation.id}: #{e.message}")
      respond_with_error(
        "A especificação do vídeo não é válida. Por favor, peça ao assistente para gerar " \
        "uma descrição detalhada da animação que você deseja criar."
      )
    rescue RemotionService::ApiError, RemotionService::RenderError => e
      Rails.logger.error("[VideoController] Preview error for conv=#{@conversation.id}: #{e.message}")

      # Check if it's an invalid prompt error from Remotion
      if e.message.include?("Invalid prompt")
        Rails.logger.error("[VideoController] Remotion rejected prompt as invalid")
        respond_with_error(
          "A especificação do vídeo foi rejeitada. Por favor, peça ao assistente para " \
          "criar uma descrição mais detalhada da animação, incluindo termos como " \
          "'animação', 'transição', 'efeito', ou especificações técnicas."
        )
      else
        @conversation.mark_error!(e.message)
        respond_with_error(t("video.preview_failed"))
      end
    end
  end

  # ---------------------------------------------------------------------------
  # POST /conversations/:conversation_id/video/approve
  #
  # User approved the preview — kick off the full async render and close the
  # conversation (so no further prompts can be sent).
  # ---------------------------------------------------------------------------
  def approve
    return respond_with_error(t("video.cannot_approve")) unless @conversation.previewing? || @conversation.spec_ready?

    begin
      # Get the component source stored during preview generation
      component_code = @conversation.component_code

      if component_code.blank?
        Rails.logger.error("[VideoController] No component_code for conversation=#{@conversation.id}")
        return respond_with_error("No component available for rendering. Please generate a preview first.")
      end

      # Use extracted configuration if available, otherwise use defaults
      config = @conversation.video_spec || {}

      result = RemotionService.start_render(
        @conversation,
        component_code,
        width: config["width"] || 1920,
        height: config["height"] || 1080,
        fps: config["fps"] || 60,
        duration_in_frames: config["duration_in_frames"] || 300,
        codec: "h264",
        video_bitrate: "10M"
      )

      @conversation.mark_rendering!(result[:render_id])

      # The Node render call is synchronous — the video is already done by the
      # time it responds, so persist the final state immediately.
      @conversation.mark_done!(result[:video_url]) if result[:status] == "done"

      # Keep session key for backward compatibility (Node no longer returns bucket_name)
      session["bucket_name_#{@conversation.id}"] = "local"

      Rails.logger.info(
        "[VideoController] Final render started for conversation=#{@conversation.id} " \
        "user=#{current_user.id} render_id=#{result[:render_id]}"
      )

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "video_preview_panel",
              partial: "chat/video_preview",
              locals: { conversation: @conversation }
            ),
            turbo_stream.replace(
              "chat_form",
              partial: "chat/form",
              locals: { conversation: @conversation }
            )
          ]
        end
        format.json do
          render json: { render_id: result[:render_id], status: "rendering" }
        end
        format.html { redirect_to chat_path(conversation_id: @conversation.id) }
      end
    rescue RemotionService::ConfigurationError => e
      Rails.logger.error("[VideoController] Remotion misconfigured: #{e.message}")
      respond_with_error(t("video.service_misconfigured"))
    rescue RemotionService::ApiError, RemotionService::RenderError => e
      Rails.logger.error("[VideoController] Render error for conv=#{@conversation.id}: #{e.message}")
      @conversation.mark_error!(e.message)
      respond_with_error(t("video.render_failed"))
    end
  end

  # ---------------------------------------------------------------------------
  # GET /conversations/:conversation_id/video/status
  #
  # Polled by the frontend (Stimulus controller + setInterval) to check render
  # progress. Returns JSON so it can be consumed directly from JS.
  #
  # When the render completes, this action updates the conversation record and
  # returns the final state so the UI can stop polling and show the result.
  # ---------------------------------------------------------------------------
  def status
    render_id = @conversation.render_id

    if render_id.blank?
      return render json: {
        status: @conversation.video_status || "idle",
        progress: 0
      }
    end

    # If we already know it's done or errored, return immediately without
    # hitting the Node service again.
    if @conversation.video_done?
      return render json: {
        status: "done",
        progress: 100,
        video_path: @conversation.video_file_path
      }
    end

    return render json: { status: "error", progress: 0 } if @conversation.video_error?

    begin
      # Use local bucket for local rendering
      bucket_name = session["bucket_name_#{@conversation.id}"] || "local"

      result = RemotionService.check_status(render_id, bucket_name) # bucket_name unused by Node, kept for compat
      # result = { status:, progress:, video_url:, error:, current_frame:, total_frames: }

      if result[:status] == "done" && @conversation.rendering?
        # Persist the final state
        video_path = result[:video_url]
        @conversation.mark_done!(video_path)
        Rails.logger.info(
          "[VideoController] Render done for conv=#{@conversation.id} path=#{video_path}"
        )
      elsif result[:status] == "error" && !@conversation.video_error?
        @conversation.mark_error!(result[:error])
        Rails.logger.error(
          "[VideoController] Render error for conv=#{@conversation.id}: #{result[:error]}"
        )
      end

      render json: {
        render_id: render_id,
        status: result[:status],
        progress: (result[:progress] * 100).to_i,
        video_url: result[:video_url],
        error: result[:error],
        current_frame: result[:current_frame],
        total_frames: result[:total_frames]
      }
    rescue RemotionService::NotFoundError
      # Job not found — could be a server restart. Mark as error.
      @conversation.mark_error!("Render job not found on service")
      render json: { status: "error", progress: 0 }
    rescue RemotionService::ApiError => e
      Rails.logger.warn("[VideoController] Status poll error for conv=#{@conversation.id}: #{e.message}")
      # Don't mark as error on transient poll failures — let the client retry
      render json: {
        status: @conversation.video_status,
        progress: 0,
        warning: "Could not reach Remotion service"
      }
    end
  end

  # ---------------------------------------------------------------------------
  # private
  # ---------------------------------------------------------------------------
  private

  # Find the conversation belonging to the current user.
  # If the conversation_id doesn't belong to this user, raise RecordNotFound
  # so Rails renders a 404 — this prevents user enumeration attacks.
  def set_conversation
    @conversation = current_user.claude_conversations.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.turbo_stream { head :not_found }
      format.json         { render json: { error: "Not found" }, status: :not_found }
      format.html         { redirect_to chat_path, alert: t("video.not_found") }
    end
  end

  # Extra guard: ensure the conversation was actually found (set_conversation may
  # have rendered and returned early via rescue).
  def authorize_conversation!
    return if @conversation.present?

    head :not_found
  end

  # Unified error responder for Turbo Stream / JSON / HTML formats.
  def respond_with_error(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "video_preview_panel",
          partial: "chat/video_preview",
          locals: { conversation: @conversation, error: message }
        ), status: :unprocessable_content
      end
      format.json do
        render json: { error: message }, status: :unprocessable_content
      end
      format.html do
        redirect_to chat_path(conversation_id: @conversation.id), alert: message
      end
    end
  end
end
