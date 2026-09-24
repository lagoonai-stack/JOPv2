# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Webhooks", type: :request do
  let(:user) { create(:user) }

  let(:event_payload) do
    {
      "id" => "evt_123",
      "type" => "checkout.session.completed",
      "data" => {
        "object" => {
          "id" => "cs_123",
          "payment_status" => "paid",
          "amount_total" => 4990,
          "currency" => "brl",
          "customer_email" => user.email,
          "metadata" => { "user_id" => user.id.to_s, "plan" => "starter" }
        }
      }
    }
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("STRIPE_WEBHOOK_SECRET", nil).and_return("whsec_test")
    allow(Stripe::Webhook).to receive(:construct_event).and_return(
      Stripe::Event.construct_from(event_payload)
    )
  end

  describe "POST /webhooks/stripe" do
    context "without signature" do
      it "returns bad request" do
        post "/webhooks/stripe", params: event_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with valid signature" do
      before do
        # Bypass signature verification in request spec (request body not available as raw in integration test)
        stripe_event = Stripe::Event.construct_from(event_payload)
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(WebhooksController).to receive(:verify_stripe_signature) do |controller|
          controller.instance_variable_set(:@stripe_event, stripe_event)
        end
        # rubocop:enable RSpec/AnyInstance
      end

      it "creates payment and updates user subscription" do
        post "/webhooks/stripe",
             params: event_payload.to_json,
             headers: {
               "CONTENT_TYPE" => "application/json",
               "HTTP_STRIPE_SIGNATURE" => "v1,fake_sig"
             }
        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.subscription_plan).to eq("starter")
        expect(user.subscription_period_ends_at).to be_present
        payment = Payment.find_by(stripe_session_id: "cs_123")
        expect(payment).to be_present
        expect(payment.plan).to eq("starter")
        expect(payment.amount_cents).to eq(4990)
        expect(payment.status).to eq("completed")
      end

      it "enqueues payment success email" do
        expect do
          post "/webhooks/stripe",
               params: event_payload.to_json,
               headers: {
                 "CONTENT_TYPE" => "application/json",
                 "HTTP_STRIPE_SIGNATURE" => "v1,fake_sig"
               }
        end.to have_enqueued_mail(PaymentMailer, :payment_success)
      end
    end
  end
end
