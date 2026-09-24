# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Chat (Just One Prompt)", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_subscription, confirmed_at: Time.current) }

  describe "GET /chat" do
    context "when not logged in" do
      it "redirects to sign in" do
        get chat_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("/users/sign_in")
      end
    end

    context "when logged in" do
      before { sign_in user, scope: :user }

      it "returns success and shows chat page" do
        get chat_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Just One Prompt")
        expect(response.body).to include("Plan:")
      end

      it "shows a specific conversation when conversation_id is given" do
        conv = user.claude_conversations.create!(agent_name: ClaudeConversation::AGENT_NAME)
        conv.claude_messages.create!(role: "user", content: "Hi")
        conv.claude_messages.create!(role: "assistant", content: "Hello!", input_tokens: 1, output_tokens: 2)

        get chat_path(conversation_id: conv.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Hi")
        expect(response.body).to include("Hello!")
      end

      it "shows read-only message when viewing a finished conversation" do
        conv = user.claude_conversations.create!(agent_name: ClaudeConversation::AGENT_NAME, finished_at: 1.hour.ago)

        get chat_path(conversation_id: conv.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("finished conversation").or include("finalizada")
      end

      it "includes messages target for auto-scroll" do
        get chat_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("chat_messages")
        expect(response.body).to include("chat_page_target").or include("chat-page-target")
      end
    end
  end

  describe "POST /chat" do
    before { sign_in user, scope: :user }

    it "creates user and assistant messages and returns turbo stream" do
      service = instance_double(OpenaiService,
                                chat: { content: "Hello! How can I help?", input_tokens: 10, output_tokens: 12,
                                        cache_creation_input_tokens: 0, cache_read_input_tokens: 0 })
      allow(OpenaiService).to receive(:new).and_return(service)

      post chat_path, params: { content: "I want to write a short film." },
                      headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")

      conv = user.claude_conversations.where(agent_name: "movie-maker").order(created_at: :desc).first
      expect(conv).to be_present
      expect(conv.claude_messages.count).to eq(2)
      user_msg = conv.claude_messages.find_by(role: "user")
      assistant_msg = conv.claude_messages.find_by(role: "assistant")
      expect(user_msg.content).to eq("I want to write a short film.")
      expect(assistant_msg.content).to eq("Hello! How can I help?")
      expect(assistant_msg.input_tokens).to eq(10)
      expect(assistant_msg.output_tokens).to eq(12)
    end

    it "redirects with alert when content is blank" do
      post chat_path, params: { content: "   " }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include("/chat")
      follow_redirect!
      expect(response.body).to include("Message can't be blank.").or include("blank")
    end

    it "returns 403 when conversation is finished" do
      conv = user.claude_conversations.create!(agent_name: ClaudeConversation::AGENT_NAME, finished_at: 1.hour.ago)
      allow(OpenaiService).to receive(:new).and_return(instance_double(OpenaiService,
                                                                       chat: { content: "Hi", input_tokens: 0,
                                                                               output_tokens: 0 }))

      post chat_path(conversation_id: conv.id), params: { content: "Hello" },
                                                headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:forbidden)
      expect(conv.claude_messages.count).to eq(0)
    end
  end

  describe "POST /chat/finish" do
    before { sign_in user, scope: :user }

    it "finishes the active conversation and redirects to chat" do
      active = user.active_claude_conversation(ClaudeConversation::AGENT_NAME) ||
               user.claude_conversations.create!(agent_name: ClaudeConversation::AGENT_NAME)
      expect(active.finished_at).to be_nil

      post finish_chat_path

      expect(response).to have_http_status(:redirect)
      expect(response.location).to include("/chat")
      active.reload
      expect(active.finished_at).to be_present
    end
  end
end
