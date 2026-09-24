# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Checkout", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }

  before do
    host! "www.example.com"
    allow(Stripe::Checkout::Session).to receive(:create).and_return(
      double(url: "https://checkout.stripe.com/fake", id: "cs_123")
    )
  end

  describe "POST /checkout/create" do
    context "with valid plan" do
      it "creates a Stripe session and redirects" do
        sign_in user, scope: :user
        post checkout_create_path, params: { plan: "starter" }
        expect(response).to redirect_to("https://checkout.stripe.com/fake")
        expect(Stripe::Checkout::Session).to have_received(:create).with(
          hash_including(
            mode: "payment",
            metadata: hash_including("plan" => "starter", "user_id" => user.id.to_s)
          )
        )
      end

      it "allows guest and does not include user_id in metadata" do
        post checkout_create_path, params: { plan: "pro" }
        expect(response).to redirect_to("https://checkout.stripe.com/fake")
        expect(Stripe::Checkout::Session).to have_received(:create).with(
          hash_including(metadata: hash_including("plan" => "pro"))
        )
      end
    end

    context "with invalid plan" do
      it "redirects to root with alert" do
        post checkout_create_path, params: { plan: "invalid" }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET /checkout/success" do
    let(:stripe_session) do
      double(id: "cs_123", metadata: { "user_id" => user.id.to_s }, customer_email: "test@example.com",
             customer_details: double(email: "test@example.com"))
    end

    let(:stripe_service) do
      instance_double(
        StripeService,
        process_checkout_completed?: true,
        create_checkout_session: double(id: "cs_123", url: "https://checkout.stripe.com/fake")
      )
    end

    before do
      allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(stripe_session)
      allow(StripeService).to receive(:new).and_return(stripe_service)
      allow(User).to receive(:find_by).and_return(user)
    end

    it "redirects to chat_path when session_id present and matches pending session" do
      sign_in user, scope: :user
      post checkout_create_path, params: { plan: "starter" }
      expect(response).to have_http_status(:redirect)
      get checkout_success_path, params: { session_id: "cs_123" }
      expect(response).to redirect_to(chat_path)
    end

    it "redirects to root with error when session_id does not match pending session" do
      sign_in user, scope: :user
      get checkout_success_path, params: { session_id: "cs_123" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects to root when session_id missing" do
      get checkout_success_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /checkout/cancel" do
    it "redirects to root with alert" do
      get checkout_cancel_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t("checkout.cancelled"))
    end
  end
end
