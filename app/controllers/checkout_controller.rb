# frozen_string_literal: true

class CheckoutController < ApplicationController
  before_action :set_plan, only: [:create]

  def create
    stripe_session = StripeService.new.create_checkout_session(
      plan_key: params[:plan],
      user: user_signed_in? ? current_user : nil
    )
    # Vincula o callback de sucesso a este navegador para evitar abuso via vazamento de session_id
    session[:pending_stripe_session_id] = stripe_session.id

    redirect_to stripe_session.url, status: :see_other, allow_other_host: true
  rescue StripeService::InvalidPlan
    redirect_to root_path, alert: t("checkout.invalid_plan")
  rescue Stripe::StripeError => e
    Rails.logger.error "Checkout error: #{e.message}"
    redirect_to root_path, alert: t("checkout.error")
  end

  def success
    @session_id = params[:session_id]
    return redirect_to root_path if @session_id.blank?
    # Aceita o sucesso apenas se este navegador iniciou o checkout (evita abuso via vazamento de session_id)
    return redirect_to root_path, alert: t("checkout.error") if session[:pending_stripe_session_id] != @session_id

    begin
      stripe_session = Stripe::Checkout::Session.retrieve(@session_id)
      StripeService.new.process_checkout_completed?(stripe_session)
      sign_in_user_from_session(stripe_session) unless user_signed_in?
      session.delete(:pending_stripe_session_id)
      redirect_to chat_path, notice: t("checkout.success_notice")
    rescue Stripe::InvalidRequestError
      redirect_to root_path, alert: t("checkout.error")
    end
  end

  def cancel
    redirect_to root_path, alert: t("checkout.cancelled")
  end

  private

  def sign_in_user_from_session(stripe_session)
    return unless stripe_session.metadata["user_id"].present? || stripe_session.customer_email.present?

    user = User.find_by(id: stripe_session.metadata["user_id"]) ||
           User.find_by(email: stripe_session.customer_email || stripe_session.customer_details&.email)
    sign_in(user) if user
  end

  def set_plan
    plan_key = params[:plan].to_s.downcase
    redirect_to root_path, alert: t("checkout.invalid_plan") and return if plan_key == "free"

    @plan = Rails.application.config.stripe_plans[plan_key]
    return if @plan

    redirect_to root_path, alert: t("checkout.invalid_plan") and return
  end
end
