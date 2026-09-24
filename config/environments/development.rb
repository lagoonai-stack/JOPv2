require "active_support/core_ext/integer/time"

Rails.application.configure do
  # As configurações aqui têm precedência sobre as de config/application.rb.

  # Alterações no código entram em vigor imediatamente sem reiniciar o servidor.
  config.enable_reloading = true

  # Não carrega todo o código no boot.
  config.eager_load = false

  # Exibe relatórios de erro completos.
  config.consider_all_requests_local = true

  # Ativa server timing.
  config.server_timing = true

  # Habilita/desabilita cache do Action Controller. Por padrão está desabilitado.
  # Execute rails dev:cache para alternar o cache do Action Controller.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Troque para :null_store para evitar qualquer cache.
  config.cache_store = :memory_store

  # Armazena arquivos enviados no sistema de arquivos local (veja config/storage.yml).
  config.active_storage.service = :local

  config.action_mailer.delivery_method = ENV["IS_DOCKER"] == "true" ? :letter_opener_web : :letter_opener
  config.action_mailer.perform_deliveries = true

  # Não se preocupa se o mailer não conseguir enviar.
  config.action_mailer.raise_delivery_errors = false

  # Aplica alterações nas templates de e-mail imediatamente.
  config.action_mailer.perform_caching = false

  # Permite o host Docker para que o Stripe CLI (container stripe) encaminhe webhooks para http://web:3000
  config.hosts << "web" << "web:3000" if ENV["IS_DOCKER"] == "true"

  # Define localhost como host para links gerados nas templates de mailer.
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  Rails.application.routes.default_url_options = { host: "localhost", port: 3000 }

  # Exibe avisos de depreciação no logger do Rails.
  config.active_support.deprecation = :log

  # Lança erro na carga de página se houver migrations pendentes.
  config.active_record.migration_error = :page_load

  # Destaca no log o código que disparou queries ao banco.
  config.active_record.verbose_query_logs = true

  # Adiciona comentários com informações de runtime nas queries SQL nos logs.
  config.active_record.query_log_tags_enabled = true

  # Destaca no log o código que enfileirou um job em background.
  config.active_job.verbose_enqueue_logs = true

  # Destaca no log o código que disparou um redirect.
  config.action_dispatch.verbose_redirect_logs = true

  # Suprime logs de requests de assets.
  config.assets.quiet = true

  # Lança erro para traduções ausentes.
  # config.i18n.raise_on_missing_translations = true

  # Anota as views renderizadas com os nomes dos arquivos.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Descomente para permitir acesso ao Action Cable de qualquer origem.
  # config.action_cable.disable_request_forgery_protection = true

  # Lança erro quando as opções only/except de before_action referenciam actions inexistentes.
  config.action_controller.raise_on_missing_callback_actions = true

  # Aplica autocorreção do RuboCop nos arquivos gerados por `bin/rails generate`.
  # config.generators.apply_rubocop_autocorrect_after_generate!
end
