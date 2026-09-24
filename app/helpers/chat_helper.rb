# frozen_string_literal: true

module ChatHelper
  # Retorna o uso como percentual (0–100) para largura no CSS. Seguro quando max_tokens é 0.
  def chat_usage_width_percent(tokens_used, max_tokens)
    return 0 if max_tokens.to_f.zero?

    (tokens_used / max_tokens.to_f * 100).clamp(0, 100)
  end

  # Retorna o percentual de uso como string formatada para exibição (ex: "12.3").
  def chat_usage_display_percent(tokens_used, max_tokens)
    return "0" if max_tokens.to_f.zero?

    ((tokens_used / max_tokens.to_f) * 100).clamp(0, 100).round(1).to_s
  end

  # Retorna true quando o usuário atingiu o limite de tokens do plano.
  def chat_usage_at_limit?(tokens_used, max_tokens)
    max_tokens.to_i.positive? && tokens_used.to_i >= max_tokens.to_i
  end
end
