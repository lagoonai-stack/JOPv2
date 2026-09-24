# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_stripe_signature

  def stripe
    event = @stripe_event
    case event.type
    when "checkout.session.completed"
      StripeService.new.process_checkout_completed?(event.data.object)
    else
      Rails.logger.info "Unhandled Stripe event: #{event.type}"
    end
    head :ok
  rescue StandardError => e
    Rails.logger.error "Webhook error: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    head :unprocessable_content
  end

  private

  # Verifica o webhook usando o body bruto e a assinatura. Nunca confiar nos params para o payload do evento.
  def verify_stripe_signature
    payload = request.raw_post
    sig = request.env["HTTP_STRIPE_SIGNATURE"]
    secret = Rails.configuration.stripe[:webhook_secret]
    if secret.blank? || sig.blank?
      head :bad_request
      return
    end
    @stripe_event = Stripe::Webhook.construct_event(payload, sig, secret)
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end
end
