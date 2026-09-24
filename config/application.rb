require_relative "boot"

require "rails/all"

# Carrega as gems listadas no Gemfile, incluindo as restritas a :test, :development ou :production.
Bundler.require(*Rails.groups)

module OnePrompt
  class Application < Rails::Application
    # Inicializa os padrões de configuração para a versão do Rails em que a aplicação foi gerada.
    config.load_defaults 8.1

    # Adicione ao `ignore` quaisquer subdiretórios de `lib` que não contenham
    # arquivos `.rb` ou que não devam ser recarregados nem eager loaded.
    # Exemplos comuns: `templates`, `generators` ou `middleware`.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuração para a aplicação, engines e railties.
    #
    # Essas configurações podem ser sobrescritas em ambientes específicos usando os arquivos
    # em config/environments, que são processados depois.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.middleware.use Rack::Attack
    config.active_storage.draw_routes = false
    config.action_mailbox.draw_routes = false

    config.i18n.load_path += Rails.root.glob("config/locales/**/*.{rb,yml}")
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en pt-BR]
    config.i18n.fallbacks = [:en]
  end
end
