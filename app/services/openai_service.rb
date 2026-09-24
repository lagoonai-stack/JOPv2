# frozen_string_literal: true

require "openai"

class OpenaiService
  class Error < StandardError; end
  class MissingApiKey < Error; end
  class ApiError < Error; end

  DEFAULT_AGENT = ClaudeConversation::AGENT_NAME
  REQUEST_TIMEOUT = 180

  class << self
    def default_client(api_key)
      @default_client ||= OpenAI::Client.new(
        api_key: api_key,
        timeout: REQUEST_TIMEOUT,
        max_retries: 2
      )
    end
  end

  def initialize(api_key: ENV.fetch("OPENAI_API_KEY", nil), client: nil)
    raise MissingApiKey, "OPENAI_API_KEY is not set" if api_key.blank?

    @client = client || self.class.default_client(api_key)
  end

  # Database models retain their historical Claude names to preserve existing data.
  # The public response shape also stays unchanged so token limits and chat storage
  # continue to work without a migration.
  def chat(messages:, agent_name: DEFAULT_AGENT)
    config = agent_config(agent_name)
    response = @client.responses.create(
      model: config[:model],
      instructions: config[:system_prompt],
      input: normalize_messages(messages),
      max_output_tokens: config[:max_tokens],
      store: false
    )
    usage = response.usage
    cached_tokens = usage&.input_tokens_details&.cached_tokens.to_i

    Rails.logger.info(
      "[OpenAI] model=#{config[:model]} input=#{usage&.input_tokens} output=#{usage&.output_tokens} " \
      "cached_input=#{cached_tokens} request_id=#{response._request_id}"
    )

    {
      content: response.output_text.to_s,
      input_tokens: usage&.input_tokens.to_i,
      output_tokens: usage&.output_tokens.to_i,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: cached_tokens
    }
  rescue OpenAI::Errors::APIError => e
    raise ApiError, e.message
  end

  private

  def normalize_messages(messages)
    messages.map do |message|
      {
        role: message[:role].to_sym,
        content: message[:content].to_s
      }
    end
  end

  def agent_config(name)
    config = Rails.application.config.openai_agents[name.to_s]
    raise ArgumentError, "Unknown agent: #{name}" unless config

    {
      system_prompt: config[:system_prompt],
      model: config[:model],
      max_tokens: config[:max_tokens]
    }
  end
end
