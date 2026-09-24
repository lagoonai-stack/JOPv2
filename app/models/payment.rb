# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :user

  validates :plan, presence: true, inclusion: { in: %w[starter pro] }
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending completed failed refunded] }

  scope :completed, -> { where(status: "completed") }
  scope :in_last_days, ->(days: 30) { where(created_at: days.days.ago..) }

  # Receita média por dia (valor total no período / número de dias)
  def self.average_amount_per_day(days: 30)
    return 0 if days < 1

    total = completed.in_last_days(days: days).sum(:amount_cents)
    (total.to_f / days).round(2)
  end

  # Número médio de pagamentos concluídos por dia no período
  def self.average_payments_count_per_day(days: 30)
    return 0 if days < 1

    count = completed.in_last_days(days: days).count
    (count.to_f / days).round(2)
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[amount_cents created_at currency plan status stripe_payment_intent_id stripe_session_id]
  end
end
