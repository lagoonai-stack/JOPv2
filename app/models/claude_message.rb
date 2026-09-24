# frozen_string_literal: true

class ClaudeMessage < ApplicationRecord
  belongs_to :claude_conversation

  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true

  # Média de tokens (input + output) por dia nos últimos N dias.
  # Usa os valores reais retornados pela API — sem estimativas por comprimento de conteúdo.
  def self.average_tokens_per_day(days: 30)
    return 0 if days < 1

    total = where(role: "assistant", created_at: days.days.ago..).sum("input_tokens + output_tokens")
    (total.to_f / days).round(2)
  end
end
