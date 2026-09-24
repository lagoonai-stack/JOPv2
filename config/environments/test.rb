# O ambiente de teste é usado exclusivamente para rodar a suíte de testes da aplicação.
# Nunca é necessário trabalhar com ele em outro contexto. Lembre-se que o banco de dados
# de teste é um "rascunho" da suíte e é zerado e recriado entre as execuções dos testes.
# Não dependa dos dados armazenados nele!

Rails.application.configure do
  # As configurações aqui têm precedência sobre as de config/application.rb.

  # Durante os testes os arquivos não são monitorados, então recarregamento não é necessário.
  config.enable_reloading = false

  # Eager loading carrega toda a aplicação. Ao rodar um único teste localmente,
  # isso geralmente não é necessário e pode tornar a suíte mais lenta. Porém, é
  # recomendado habilitá-lo em sistemas de integração contínua para garantir que
  # o eager loading funcione corretamente antes do deploy.
  config.eager_load = ENV["CI"].present?

  # Configura o servidor de arquivos públicos nos testes com cache-control para performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Exibe relatórios de erro completos.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Renderiza templates de exceção para exceções resgatáveis e lança para as demais.
  config.action_dispatch.show_exceptions = :rescuable

  # Desabilita proteção contra CSRF no ambiente de teste.
  config.action_controller.allow_forgery_protection = false

  # Armazena arquivos enviados no sistema de arquivos local em um diretório temporário.
  config.active_storage.service = :test

  # Instrui o Action Mailer a não entregar e-mails reais.
  # O método de entrega :test acumula os e-mails enviados no array
  # ActionMailer::Base.deliveries.
  config.action_mailer.delivery_method = :test

  # Define o host para links gerados nas templates de mailer e URL helpers.
  config.action_mailer.default_url_options = { host: "example.com" }
  config.action_controller.default_url_options = { host: "example.com" }

  # Exibe avisos de depreciação no stderr.
  config.active_support.deprecation = :stderr

  # Lança erro para traduções ausentes.
  # config.i18n.raise_on_missing_translations = true

  # Anota as views renderizadas com os nomes dos arquivos.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Lança erro quando as opções only/except de before_action referenciam actions inexistentes.
  config.action_controller.raise_on_missing_callback_actions = true

  # Garante que URL helpers usados fora do contexto de request (ex: em services) tenham um host.
  config.after_initialize do
    Rails.application.routes.default_url_options ||= {}
    Rails.application.routes.default_url_options.merge!(host: "example.com", protocol: "http")
  end
end
