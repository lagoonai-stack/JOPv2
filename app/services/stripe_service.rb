# frozen_string_literal: true

class StripeService
  class Error < StandardError; end
  class InvalidPlan < Error; end

  PLANS = Rails.application.config.stripe_plans.keys.reject { |k| k == "free" }.freeze

  def initialize
    @api_key = Rails.configuration.stripe[:secret_key]
  end

  # Cria uma Sessão de Checkout Stripe para o plano informado.
  # @param plan_key [String] "starter" ou "pro"
  # @param user [User, nil] opcional; quando presente, os metadados incluem user_id e customer_email
  # @return [Stripe::Checkout::Session]
  def create_checkout_session(plan_key:, user: nil)
    raise InvalidPlan, "Invalid plan" unless valid_plan?(plan_key)

    plan = plan_config(plan_key)

    # Omita "payment_method_types" para gerenciar os métodos de pagamento pelo Stripe Dashboard.
    opts = {
      mode: "payment",
      # payment_method_types: %w[card],
      line_items: [line_item_for(plan)],
      success_url: success_url,
      cancel_url: cancel_url,
      metadata: { "plan" => plan_key.to_s }
    }
    opts[:customer_email] = user.email if user&.email.present?
    opts[:metadata]["user_id"] = user.id.to_s if user.present?

    Stripe::Checkout::Session.create(**opts)
  end

  # Processa um evento checkout.session.completed bem-sucedido.
  # Cria o pagamento, atualiza a assinatura do usuário e enfileira o e-mail de confirmação.
  # @param session [Stripe::Checkout::Session]
  # @return [true, false] true se processado, false se ignorado (ex: já processado anteriormente)
  def process_checkout_completed?(session)
    return false if session.payment_status != "paid"

    plan = session.metadata["plan"].to_s.downcase
    return false unless plan.in?(PLANS)

    user = find_or_assign_user(session)
    return false unless user

    return false if Payment.exists?(stripe_session_id: session.id)

    ActiveRecord::Base.transaction do
      create_payment!(session, user, plan)
      update_user_subscription!(user, plan)
    end
    send_success_mail!(user, plan)

    true
  end

  private

  def valid_plan?(key)
    key.to_s.downcase.in?(PLANS)
  end

  def plan_config(plan_key)
    cfg = Rails.application.config.stripe_plans[plan_key.to_s.downcase]
    raise InvalidPlan, "Unknown plan" unless cfg

    cfg
  end

  def line_item_for(plan)
    product_data = {
      name: plan[:name]
    }
    product_data[:description] = plan[:description] if plan[:description].present?

    {
      price_data: {
        currency: plan[:currency],
        unit_amount: plan[:price_cents],
        product_data: product_data
      },
      quantity: 1
    }
  end

  def success_url
    "#{Rails.application.routes.url_helpers.checkout_success_url}?session_id={CHECKOUT_SESSION_ID}"
  end

  def cancel_url
    Rails.application.routes.url_helpers.checkout_cancel_url
  end

  def find_or_assign_user(session)
    user_id = session.metadata["user_id"].presence
    user = user_id.present? ? User.find_by(id: user_id.to_i) : nil
    user || find_or_create_user_from_session(session)
  end

  def find_or_create_user_from_session(session)
    email = session.customer_email.presence || session.customer_details&.email
    return nil if email.blank?

    user = User.find_by(email: email)
    return user if user

    base_username = email.split("@").first.to_s.gsub(/[^a-z0-9_]/, "").downcase[0, 20].presence || "user"
    username = base_username
    n = 0
    username = "#{base_username}_#{n += 1}" while User.exists?(username: username)

    pass = SecureRandom.alphanumeric(16)
    user = User.new(email: email, username: username, password: pass, password_confirmation: pass)
    # O Stripe já validou este e-mail no momento do pagamento — ignoramos a confirmação do Devise.
    # Enviamos imediatamente um link de redefinição de senha para que o usuário defina suas credenciais.
    user.skip_confirmation!
    user.save!
    user.send_reset_password_instructions
    user
  end

  def create_payment!(session, user, plan)
    Payment.create!(
      user: user,
      plan: plan,
      amount_cents: session.amount_total,
      currency: session.currency,
      stripe_session_id: session.id,
      status: "completed"
    )
  end

  def update_user_subscription!(user, plan)
    user.update!(
      subscription_plan: plan,
      subscription_period_started_at: Time.current,
      subscription_period_ends_at: 1.month.from_now
    )
  end

  def send_success_mail!(user, plan)
    plan_details = Rails.application.config.stripe_plans[plan]
    PaymentMailer.with(user: user, plan: plan_details).payment_success.deliver_later
  end
end
