# frozen_string_literal: true

require "cgi"

class ClaudeConversation < ApplicationRecord
  AGENT_NAME = "movie-maker"

  # ── Video pipeline states ──────────────────────────────────────────────────
  # idle        → conversation in progress, no spec yet
  # spec_ready  → AI generated the JSON spec, ready to preview
  # previewing  → preview requested from Node, token issued
  # approved    → user approved the preview, render started
  # rendering   → Node is rendering the final video
  # done        → render complete, video_file_path set
  # error       → something went wrong in preview or render
  VIDEO_STATUSES = %w[idle spec_ready previewing approved rendering done error].freeze

  belongs_to :user
  has_many :claude_messages, dependent: :destroy

  validates :agent_name, presence: true
  validates :video_status, inclusion: { in: VIDEO_STATUSES }, allow_nil: true

  scope :active,   -> { where(finished_at: nil) }
  scope :finished, -> { where.not(finished_at: nil) }

  # ── Lifecycle predicates ───────────────────────────────────────────────────

  def active?
    finished_at.nil?
  end

  def finished?
    !active?
  end

  # ── Video pipeline predicates ──────────────────────────────────────────────

  def video_idle?
    video_status.nil? || video_status == "idle"
  end

  def spec_ready?
    video_status == "spec_ready"
  end

  def previewing?
    video_status == "previewing"
  end

  def approved?
    video_status == "approved"
  end

  def rendering?
    video_status == "rendering"
  end

  def video_done?
    video_status == "done"
  end

  def video_error?
    video_status == "error"
  end

  # True while the Node service is actively working (preview or render in-flight)
  def video_processing?
    previewing? || rendering?
  end

  # Preview token is present and has not expired
  def preview_token_valid?
    preview_token.present? &&
      preview_token_expires_at.present? &&
      preview_token_expires_at > Time.current
  end

  # ── Token helpers ──────────────────────────────────────────────────────────

  # Returns the full URL to the Remotion Node preview player page.
  # This is what gets embedded in the Rails iframe. Uses the PUBLIC_URL (not
  # the Docker-internal REMOTION_SERVICE_URL) since the browser loads it directly.
  def preview_player_url
    return nil if preview_token.blank?

    "#{RemotionService::PUBLIC_URL}/embed/#{preview_token}"
  end

  # ── Token management ──────────────────────────────────────────────────────

  def store_preview_token!(token:, expires_at:)
    update!(
      preview_token: token,
      preview_token_expires_at: expires_at,
      video_status: "previewing"
    )
  end

  def clear_preview_token!
    update!(
      preview_token: nil,
      preview_token_expires_at: nil
    )
  end

  # ── State transitions ─────────────────────────────────────────────────────

  def mark_spec_ready!(spec)
    update!(
      video_spec: spec,
      video_status: "spec_ready"
    )
  end

  # Store the component_id after uploading TSX to Remotion
  def mark_component_uploaded!(component_id, metadata = {})
    attrs = metadata.slice(:generation_prompt, :ai_model, :ai_attempts, :detected_skills)
    # Convert detected_skills array to JSON if present
    attrs[:detected_skills] = attrs[:detected_skills].to_json if attrs[:detected_skills].is_a?(Array)

    update!(
      component_id: component_id,
      video_status: "spec_ready",
      **attrs
    )
  end

  # Store AI-generated component details
  def mark_component_generated!(component_id, prompt:, model: nil, attempts: nil, detected_skills: nil)
    update!(
      component_id: component_id,
      generation_prompt: prompt,
      ai_model: model,
      ai_attempts: attempts,
      detected_skills: detected_skills.is_a?(Array) ? detected_skills.to_json : detected_skills,
      video_status: "spec_ready"
    )
  end

  def mark_rendering!(render_id)
    update!(
      render_id: render_id,
      video_status: "rendering"
    )
    clear_preview_token!
  end

  # Check if using component-based rendering
  def using_component?
    component_id.present?
  end

  # Check if using legacy spec-based rendering
  def using_spec?
    video_spec.present? && component_id.blank?
  end

  # Check if component was AI-generated
  def ai_generated?
    component_id.present? && generation_prompt.present?
  end

  # Get detected skills as array
  def skills_array
    return [] if detected_skills.blank?

    JSON.parse(detected_skills)
  rescue StandardError
    []
  end

  def mark_done!(file_path)
    update!(
      video_file_path: file_path,
      video_status: "done",
      finished_at: Time.current
    )
  end

  def mark_error!(message = nil)
    update!(video_status: "error")
    Rails.logger.error("[ClaudeConversation##{id}] Video pipeline error: #{message}")
  end

  # ── Token count helpers ────────────────────────────────────────────────────

  def total_input_tokens
    claude_messages.where(role: "assistant").sum(:input_tokens)
  end

  def total_output_tokens
    claude_messages.sum(role: "assistant").sum(:output_tokens)
  end

  def total_tokens
    claude_messages.where(role: "assistant").sum("input_tokens + output_tokens")
  end

  # Monta o array de mensagens para a API (últimas N para respeitar o limite de contexto).
  # Garante que o histórico enviado ao provedor comece com uma mensagem do usuário.
  def api_messages(limit: 20)
    messages = claude_messages.order(created_at: :asc).last(limit)
    messages = messages.drop_while { |m| m.role == "assistant" }
    messages.map { |m| { role: m.role, content: m.content } }
  end
end
