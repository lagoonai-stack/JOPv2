# frozen_string_literal: true

class User < ApplicationRecord
  # Módulos Devise incluídos. Outros disponíveis:
  # :confirmable, :lockable, :timeoutable, :trackable e :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable, :confirmable

  before_validation :normalize_username

  validates :username,
            presence: true,
            length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-z0-9_]+\z/, message: ->(*) { I18n.t("devise.errors.messages.username_format") } },
            uniqueness: { case_sensitive: false }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :locale,
            presence: true,
            inclusion: { in: I18n.available_locales.map(&:to_s) }

  has_many :claude_conversations, dependent: :destroy
  has_many :payments, dependent: :nullify

  scope :created_in_last, ->(days: 30) { where(created_at: days.days.ago..) }

  # Conversa ativa mais recente (não finalizada) para o agente informado, ou nil
  def active_claude_conversation(agent_name = ClaudeConversation::AGENT_NAME)
    claude_conversations.where(agent_name: agent_name).active.order(created_at: :desc).first
  end

  # Todas as conversas do agente, mais recentes primeiro (ativas primeiro, depois finalizadas por data)
  def claude_conversations_for_agent(agent_name = ClaudeConversation::AGENT_NAME)
    claude_conversations.where(agent_name: agent_name).order(Arel.sql("finished_at IS NULL DESC"), created_at: :desc)
  end

  def total_claude_input_tokens
    ClaudeMessage.joins(:claude_conversation)
                 .where(claude_conversations: { user_id: id }, role: "assistant")
                 .sum(:input_tokens)
  end

  def total_claude_output_tokens
    ClaudeMessage.joins(:claude_conversation)
                 .where(claude_conversations: { user_id: id }, role: "assistant")
                 .sum(:output_tokens)
  end

  def total_claude_tokens
    ClaudeMessage.joins(:claude_conversation)
                 .where(claude_conversations: { user_id: id }, role: "assistant")
                 .sum("input_tokens + output_tokens")
  end

  def subscription_period
    return nil unless subscription_period_started_at && subscription_period_ends_at

    subscription_period_started_at..subscription_period_ends_at
  end

  def tokens_used_this_period
    return 0 unless subscription_period

    ClaudeMessage.joins(:claude_conversation)
                 .where(claude_conversations: { user_id: id }, role: "assistant")
                 .where(created_at: subscription_period)
                 .sum("input_tokens + output_tokens")
  end

  def plan_config
    return nil if subscription_plan.blank?

    Rails.application.config.stripe_plans[subscription_plan]
  end

  def tokens_limit_this_period
    plan_config&.dig(:max_tokens_per_month) || 0
  end

  def can_send_prompt?
    return false unless plan_config
    return false if subscription_period_ends_at && subscription_period_ends_at < Time.current

    tokens_used_this_period < tokens_limit_this_period
  end

  def free_plan?
    subscription_plan == "free"
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at email id username]
  end

  private

  def normalize_username
    self.username = username.to_s.strip.downcase
  end

  # Callback do Devise chamado após a confirmação do email.
  def after_confirmation
    assign_free_plan if subscription_plan.blank?
  end

  # Atribui plano free automaticamente após confirmação de email.
  # Período vitalício (100 anos) — o limite é apenas por tokens.
  def assign_free_plan
    update(
      subscription_plan: "free",
      subscription_period_started_at: Time.current,
      subscription_period_ends_at: 100.years.from_now,
      updated_at: Time.current
    )
  end

  # Envia emails do Devise de forma assíncrona (deliver_later)
  # para evitar timeout no request HTTP durante o cadastro.
  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end
end
