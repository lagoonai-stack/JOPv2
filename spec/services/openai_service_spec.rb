# frozen_string_literal: true

require "rails_helper"

RSpec.describe OpenaiService do
  subject(:service) { described_class.new(api_key: "test-openai-key", client: client) }

  let(:responses) { instance_spy(OpenAI::Resources::Responses) }
  let(:client) { instance_double(OpenAI::Client, responses: responses) }

  describe "#chat" do
    it "sends the conversation through the official SDK and maps text and token usage" do
      input_token_details = instance_double(
        OpenAI::Responses::ResponseUsage::InputTokensDetails,
        cached_tokens: 80
      )
      usage = instance_double(
        OpenAI::Responses::ResponseUsage,
        input_tokens: 120,
        output_tokens: 15,
        input_tokens_details: input_token_details
      )
      response = instance_double(
        OpenAI::Responses::Response,
        output_text: "Which format do you want?",
        usage: usage,
        _request_id: "req_test"
      )
      allow(responses).to receive(:create).and_return(response)

      result = service.chat(messages: [{ role: "user", content: "Create a video" }])

      expect(responses).to have_received(:create).with(
        model: Rails.application.config.openai_agents["movie-maker"][:model],
        instructions: Rails.application.config.openai_agents["movie-maker"][:system_prompt],
        input: [{ role: :user, content: "Create a video" }],
        max_output_tokens: 25_000,
        store: false
      )
      expect(result).to include(
        content: "Which format do you want?",
        input_tokens: 120,
        output_tokens: 15,
        cache_creation_input_tokens: 0,
        cache_read_input_tokens: 80
      )
    end

    it "wraps SDK errors with the service error type" do
      sdk_error = OpenAI::Errors::APIError.new(
        url: URI("https://api.openai.com/v1/responses"),
        message: "Invalid API key"
      )
      allow(responses).to receive(:create).and_raise(sdk_error)

      expect do
        service.chat(messages: [{ role: "user", content: "Hello" }])
      end.to raise_error(described_class::ApiError, "Invalid API key")
    end
  end

  describe "#initialize" do
    it "requires an API key" do
      expect { described_class.new(api_key: nil) }
        .to raise_error(described_class::MissingApiKey, "OPENAI_API_KEY is not set")
    end
  end
end
