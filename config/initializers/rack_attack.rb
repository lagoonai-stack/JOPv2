# frozen_string_literal: true

class Rack::Attack
  # ---------------------------------------------------------------------------
  # Endpoints de autenticação — proteção contra brute-force
  # ---------------------------------------------------------------------------

  throttle("logins/ip", limit: 5, period: 1.minute) do |request|
    request.ip if request.path == "/users/sign_in" && request.post?
  end

  throttle("admin_logins/ip", limit: 5, period: 1.minute) do |request|
    request.ip if request.path == "/admin/login" && request.post?
  end

  # Janela horária mais rígida — captura brute-force lenta distribuída no tempo
  throttle("logins/ip/hourly", limit: 20, period: 1.hour) do |request|
    request.ip if request.path == "/users/sign_in" && request.post?
  end

  # ---------------------------------------------------------------------------
  # Cadastro e recuperação de senha
  # ---------------------------------------------------------------------------

  throttle("signups/ip", limit: 5, period: 1.minute) do |request|
    request.ip if request.path == "/users" && request.post?
  end

  # Resets de senha são vetores comuns de harvest de e-mails e abuso
  throttle("password_resets/ip", limit: 5, period: 5.minutes) do |request|
    request.ip if request.path == "/users/password" && request.post?
  end

  # ---------------------------------------------------------------------------
  # Checkout — previne flooding de sessões e spam de pedidos
  # ---------------------------------------------------------------------------

  throttle("checkouts/ip", limit: 10, period: 1.minute) do |request|
    request.ip if request.path == "/checkout/create" && request.post?
  end

  # ---------------------------------------------------------------------------
  # Webhook — assinatura ainda verificada por request; esta é uma proteção extra
  # ---------------------------------------------------------------------------

  throttle("webhooks/ip", limit: 60, period: 1.minute) do |request|
    request.ip if request.path == "/webhooks/stripe" && request.post?
  end

  # ---------------------------------------------------------------------------
  # Chat — proteção contra esgotamento de tokens e abuso
  # ---------------------------------------------------------------------------

  throttle("chat/ip", limit: 30, period: 1.minute) do |request|
    request.ip if request.path == "/chat" && request.post?
  end

  # Janela horária — captura clientes que distribuem requisições ao longo dos minutos
  throttle("chat/ip/hourly", limit: 300, period: 1.hour) do |request|
    request.ip if request.path == "/chat" && request.post?
  end

  # ---------------------------------------------------------------------------
  # Catch-all global — defesa contra flooding geral de requisições
  # Exclui assets estáticos (servidos antes deste middleware em produção).
  # ATENÇÃO: Rack::Attack usa Rails.cache para os contadores. Em ambiente
  # multi-processo/multi-servidor é OBRIGATÓRIO usar um cache compartilhado
  # (ex: :redis_cache_store) para que os contadores sejam compartilhados
  # entre os workers do Puma.
  # ---------------------------------------------------------------------------

  throttle("req/ip", limit: 500, period: 1.minute) do |request|
    request.ip unless request.path.start_with?("/assets", "/packs", "/up")
  end

  # ---------------------------------------------------------------------------
  # Resposta para requests bloqueados: RFC 6585 §4 — Retry-After para o cliente recuar
  # ---------------------------------------------------------------------------

  self.throttled_responder = lambda do |env|
    match_data  = env["rack.attack.match_data"]
    now         = match_data[:epoch_time]
    retry_after = (match_data[:period] - (now % match_data[:period])).ceil

    [
      429,
      {
        "Content-Type" => "text/plain",
        "Retry-After" => retry_after.to_s
      },
      ["Muitas requisições. Tente novamente em #{retry_after} segundos.\n"]
    ]
  end
end
