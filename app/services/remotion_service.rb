# frozen_string_literal: true

require "net/http"
require "openssl"
require "json"

# RemotionService
#
# Handles all communication between the Rails app and the JOP-Remotion Node service.
# Every request (POST and GET) is authenticated with an HMAC-SHA256 signature over
# the raw request body (empty string for GET), sent as the X-JOP-Signature header.
#
# Security model:
#   - Rails signs every outgoing request with HMAC-SHA256
#   - The Node service verifies the signature before processing
#   - Preview tokens are short-lived (1h on Node) and tied to a specific conversation
#   - Only the owning user can request a preview or render for their conversation
#
class RemotionService
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ApiError < Error; end
  class AuthError < Error; end
  class NotFoundError < Error; end
  class RenderError < Error; end

  # REMOTION_SERVICE_URL is used for Rails -> Node API calls (may be a Docker-internal
  # host like host.docker.internal). REMOTION_PUBLIC_URL is used to build the
  # preview/video URLs embedded in pages served to the browser, which needs a host
  # it can actually reach and defaults to the same value when not containerized.
  BASE_URL = ENV.fetch("REMOTION_SERVICE_URL", "http://localhost:3001").freeze
  PUBLIC_URL = ENV.fetch("REMOTION_PUBLIC_URL", BASE_URL).freeze
  SHARED_SECRET = ENV.fetch("REMOTION_SHARED_SECRET", nil)
  TIMEOUT_SECONDS = 300 # AI generation + rendering can take a while

  # ──────────────────────────────────────────────────────────────────────────
  # Public API
  # ──────────────────────────────────────────────────────────────────────────

  # Generate a TSX component from a prompt and save a preview in one step.
  # Calls POST /api/v1/preview on the Node service.
  #
  # @param conversation [ClaudeConversation]
  # @param prompt [String]
  # @param options [Hash] { model:, width:, height:, fps:, duration_in_frames: }
  # @return [Hash] { preview_token:, preview_url:, component_code:, detected_skills:,
  #                  width:, height:, duration_in_frames:, fps: }
  def self.generate_preview(conversation, prompt, options = {})
    new.generate_preview(conversation, prompt, options)
  end

  # Check render status — class-level alias used by rake tasks.
  # @param render_id [String]
  # @param _conversation unused
  # @return [Hash] { status:, progress:, video_url:, error: }
  def self.render_status(render_id, _conversation = nil)
    new.check_status(render_id)
  end

  # Start a final high-quality render from the component's TSX source.
  # Calls POST /api/v1/render on the Node service. This call is synchronous —
  # the Node service renders the video before responding.
  #
  # @param conversation [ClaudeConversation]
  # @param component_code [String] TSX source of the component to render
  # @param options [Hash] { width:, height:, duration_in_frames:, fps:, codec:, video_bitrate: }
  # @return [Hash] { render_id:, status:, video_url: }
  def self.start_render(conversation, component_code, options = {})
    new.start_render(conversation, component_code, options)
  end

  # Check the status of a render job.
  # Calls GET /api/v1/status/:render_id on the Node service.
  #
  # @param render_id [String]
  # @param _bucket_name [String] unused — kept for call-site compatibility
  # @return [Hash] { status:, progress:, video_url:, error: }
  def self.check_status(render_id, _bucket_name = nil)
    new.check_status(render_id)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Instance methods
  # ──────────────────────────────────────────────────────────────────────────

  def generate_preview(conversation, prompt, options = {})
    raise ConfigurationError, "REMOTION_SHARED_SECRET is not configured" if SHARED_SECRET.blank?
    raise ArgumentError, "prompt is blank" if prompt.blank?

    Rails.logger.info("[RemotionService] generate_preview conversation=#{conversation.id}")

    body = {
      prompt: prompt,
      options: {
        model: options[:model] || "gpt-6-astra",
        width: options[:width],
        height: options[:height],
        fps: options[:fps],
        durationInFrames: options[:duration_in_frames]
      }.compact,
      metadata: { conversation_id: conversation.id.to_s, user_id: conversation.user_id.to_s }
    }

    response = post("/api/v1/preview", body)
    data = parse_response!(response, :preview)[:data]

    {
      preview_token: data[:previewToken],
      preview_url: public_url(data[:previewUrl]),
      component_code: data[:componentCode],
      detected_skills: data.dig(:metadata, :detectedSkills) || [],
      width: data.dig(:metadata, :width),
      height: data.dig(:metadata, :height),
      duration_in_frames: data.dig(:metadata, :durationInFrames),
      fps: data.dig(:metadata, :fps)
    }
  end

  def start_render(conversation, component_code, options = {})
    raise ConfigurationError, "REMOTION_SHARED_SECRET is not configured" if SHARED_SECRET.blank?
    raise ArgumentError, "component_code is blank" if component_code.blank?

    Rails.logger.info("[RemotionService] start_render conversation=#{conversation.id}")

    body = {
      componentCode: component_code,
      options: {
        width: options[:width],
        height: options[:height],
        fps: options[:fps] || 30,
        durationInFrames: options[:duration_in_frames] || 450,
        codec: options[:codec] || "h264",
        videoBitrate: options[:video_bitrate]
      }.compact,
      metadata: { conversation_id: conversation.id.to_s, user_id: conversation.user_id.to_s }
    }

    response = post("/api/v1/render", body)
    data = parse_response!(response, :render)[:data]

    {
      render_id: data[:renderId],
      status: data[:status] || "rendering",
      video_url: public_url(data[:videoUrl])
    }
  end

  def check_status(render_id)
    raise ConfigurationError, "REMOTION_SHARED_SECRET is not configured" if SHARED_SECRET.blank?
    raise ArgumentError, "render_id is blank" if render_id.blank?

    response = get_with_hmac("/api/v1/status/#{render_id}")
    data = parse_response!(response, :status)[:data]

    case data[:status]
    when "done"
      {
        status: "done",
        progress: 1.0,
        video_url: public_url(data[:videoUrl])
      }
    when "error"
      {
        status: "error",
        progress: 0.0,
        error: data[:error]
      }
    else
      {
        status: "rendering",
        progress: data[:progress] || 0.0,
        current_frame: data[:current_frame],
        total_frames: data[:total_frames]
      }
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Health check
  # ──────────────────────────────────────────────────────────────────────────

  def self.healthy?
    uri = URI.join(BASE_URL, "/health")
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    Rails.logger.error("[RemotionService] Health check failed: #{e.message}")
    false
  end

  # ──────────────────────────────────────────────────────────────────────────
  # HMAC helpers
  # ──────────────────────────────────────────────────────────────────────────

  def self.sign_body(body_string)
    OpenSSL::HMAC.hexdigest("SHA256", SHARED_SECRET.to_s, body_string.to_s)
  end

  # ──────────────────────────────────────────────────────────────────────────
  private

  # ── HTTP helpers ──────────────────────────────────────────────────────────

  def post(path, body_hash)
    body_json = body_hash.to_json
    signature = self.class.sign_body(body_json)

    uri = URI.join(BASE_URL, path)

    http = build_http(uri)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"]    = "application/json"
    request["X-JOP-Signature"] = signature
    request["Accept"]          = "application/json"
    request.body = body_json

    log_request("POST", path, body_hash)
    http.request(request)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise ApiError, "Remotion service timed out: #{e.message}"
  rescue Errno::ECONNREFUSED, SocketError => e
    raise ApiError, "Cannot reach Remotion service at #{BASE_URL}: #{e.message}"
  end

  # GET request authenticated via the X-JOP-Signature header (as required by
  # Node's requireAuth), signed over an empty body since GET requests have none.
  def get_with_hmac(path)
    uri = URI.join(BASE_URL, path)
    signature = self.class.sign_body("")

    http = build_http(uri)
    request = Net::HTTP::Get.new(uri)
    request["X-JOP-Signature"] = signature
    request["Accept"] = "application/json"

    log_request("GET", path)
    http.request(request)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise ApiError, "Remotion service timed out: #{e.message}"
  rescue Errno::ECONNREFUSED, SocketError => e
    raise ApiError, "Cannot reach Remotion service at #{BASE_URL}: #{e.message}"
  end

  # Turn a Node-relative path (e.g. "/embed/abc123") into an absolute URL the
  # browser can load. Falls through unchanged if already absolute or blank.
  def public_url(path)
    return path if path.blank? || path.start_with?("http://", "https://")

    URI.join(PUBLIC_URL, path).to_s
  end

  def build_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl       = uri.scheme == "https"
    http.open_timeout  = 30
    http.read_timeout  = TIMEOUT_SECONDS
    http.write_timeout = 60
    http
  end

  # ── Response parsing ──────────────────────────────────────────────────────

  def parse_response!(response, context)
    body = begin
      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      { error: "Invalid JSON response from Remotion service: #{response.body.truncate(200)}" }
    end

    case response.code.to_i
    when 200, 201, 202
      log_success(context, body)
      body
    when 401
      raise AuthError, "Remotion service rejected the request signature. Check REMOTION_SHARED_SECRET."
    when 404
      raise NotFoundError, "Remotion resource not found: #{body[:message] || body[:error]}"
    when 422
      details = Array(body[:details]).join("; ")
      raise ApiError, "Remotion validation failed: #{details}"
    when 500
      raise RenderError, "Remotion service internal error: #{body[:message] || body[:error]}"
    else
      raise ApiError, "Unexpected response #{response.code} from Remotion service: #{body[:message] || body[:error]}"
    end
  end

  # ── Logging ───────────────────────────────────────────────────────────────

  def log_request(method, path, params = {})
    redacted = params.except(:componentCode, :prompt)
    Rails.logger.info("[RemotionService] #{method} #{path} #{redacted.inspect}")
  end

  def log_success(context, body)
    Rails.logger.info("[RemotionService] #{context} success: #{body.except(:code).inspect}")
  end
end
