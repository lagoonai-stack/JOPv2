require "active_support/core_ext/integer/time"

Rails.application.configure do
  # As configurações aqui têm precedência sobre as de config/application.rb.

  # Código não é recarregado entre requests.
  config.enable_reloading = false

  # Carrega todo o código no boot para melhor performance e uso de memória (ignorado por tarefas Rake).
  config.eager_load = true

  # Relatórios de erro completos desabilitados.
  config.consider_all_requests_local = false

  # Ativa cache de fragmentos nas templates de view.
  config.action_controller.perform_caching = true

  # Desabilita servir arquivos estáticos da pasta `/public` por padrão,
  # pois o Apache ou NGINX já faz isso.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Cache de assets com expiração futura longa (todos possuem digest no nome).
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Para habilitar um servidor de assets externo:
  # config.asset_host = "http://assets.example.com"

  # Armazena arquivos enviados no sistema de arquivos local (veja config/storage.yml).
  config.active_storage.service = :local

  # A aplicação roda atrás do proxy SSL do Railway.
  config.assume_ssl = true

  # Força todo o acesso via SSL, usa Strict-Transport-Security e cookies seguros.
  config.force_ssl = true

  # Para ignorar o redirect http→https no health check padrão:
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Loga no STDOUT com o request_id como tag padrão.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger($stdout)

  # Troque para "debug" para logar tudo (incluindo informações pessoais identificáveis!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Evita que health checks poluam os logs.
  config.silence_healthcheck_path = "/up"

  # Não loga depreciações.
  config.active_support.report_deprecations = false

  # Cache em memória do processo (sem banco separado). Use Redis ou solid_cache para cache compartilhado/durável.
  config.cache_store = :memory_store

  # Fila de jobs assíncrona em memória (sem banco separado). Use solid_queue ou Sidekiq para jobs em background.
  config.active_job.queue_adapter = :async

  # Ignora endereços de e-mail inválidos e não lança erros de entrega.
  # Defina como true e configure o servidor de e-mail para lançar erros imediatamente.
  # config.action_mailer.raise_delivery_errors = false

  # Define o host para links gerados nas templates de mailer e jobs em background.
  # O Railway preenche RAILWAY_PUBLIC_DOMAIN automaticamente com a URL pública.
  public_host = ENV["RAILWAY_PUBLIC_DOMAIN"].presence || ENV.fetch("ACTION_MAILER_HOST", "example.com")

  config.action_mailer.default_url_options = { host: public_host, protocol: "https" }
  config.action_controller.default_url_options = { host: public_host, protocol: "https" }

  # Garante que Rails.application.routes.url_helpers funcione em services (como StripeService)
  config.after_initialize do
    Rails.application.routes.default_url_options = { host: public_host, protocol: "https" }
  end

  # Configuração da API HTTP do Resend (SMTP é bloqueado nos planos Trial/Free do Railway)
  config.action_mailer.delivery_method = :resend
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # Ativa fallbacks de locale para I18n (busca no locale padrão quando a tradução não é encontrada).
  config.i18n.fallbacks = true

  # Não exporta o schema após migrations.
  config.active_record.dump_schema_after_migration = false

  # Usa apenas :id nas inspeções em produção.
  config.active_record.attributes_for_inspect = [ :id ]

  # Proteção contra DNS-rebinding e ataques via header Host.
  # Permite apenas o hostname público da aplicação.
  # Adicione EXTRA_HOSTS (separados por vírgula) para domínios customizados / origens CDN.
  allowed_hosts = [public_host]
  extra = ENV.fetch("EXTRA_HOSTS", "").split(",").map(&:strip).compact_blank
  allowed_hosts.concat(extra)
  config.hosts = allowed_hosts

  # Health check excluído para que o probe TCP do Railway funcione sem o header Host.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
