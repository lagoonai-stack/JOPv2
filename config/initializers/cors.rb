# CORS não é necessário para esta aplicação server-rendered (Turbo/Stimulus, mesma origem).
# Restrito ao próprio host da aplicação para prevenir abuso cross-origin.
# Defina a env var ALLOWED_ORIGINS como lista separada por vírgulas de origens permitidas.
# Usa como fallback o host derivado de RAILWAY_PUBLIC_DOMAIN / ACTION_MAILER_HOST.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed_origins =
      if Rails.env.production?
        raw = ENV.fetch("ALLOWED_ORIGINS", "")
        if raw.present?
          raw.split(",").map(&:strip)
        else
          app_host = ENV["RAILWAY_PUBLIC_DOMAIN"].presence || ENV["ACTION_MAILER_HOST"].presence
          app_host ? ["https://#{app_host}"] : []
        end
      else
        %w[http://localhost:3000 http://127.0.0.1:3000]
      end

    origins(*allowed_origins)
    resource "*",
             headers: :any,
             methods: %i[get post patch put],
             credentials: false
  end
end
