require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Aborta se o ambiente Rails estiver rodando em modo produção
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Descomente a linha abaixo caso tenha `--require rails_helper` no `.rspec`
# para evitar que generators do Rails falhem porque migrations não foram executadas ainda
# return unless Rails.env.test?
require "rspec/rails"
# Adicione requires extras abaixo desta linha. O Rails não é carregado antes deste ponto!

# Carrega arquivos ruby de suporte com matchers e macros customizados, etc., em
# spec/support/ e seus subdiretórios. Arquivos com o padrão `spec/**/*_spec.rb` são
# executados como specs por padrão. Isso significa que arquivos em spec/support que terminem
# em _spec.rb serão tanto carregados quanto executados como specs, causando execução duplicada.
# Recomenda-se não nomear arquivos com este padrão terminando em _spec.rb.
# O padrão pode ser configurado com a opção --pattern na linha de comando
# ou em ~/.rspec, .rspec ou `.rspec-local`.
#
# A linha abaixo é fornecida por conveniência. Tem a desvantagem de aumentar o
# tempo de boot ao carregar automaticamente todos os arquivos do diretório support.
# Alternativamente, nos arquivos `*_spec.rb` individuais, faça require manualmente
# apenas dos arquivos de suporte necessários.
#
Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |f| require f }

# Verifica migrations pendentes e as aplica antes de executar os testes.
# Se não estiver usando ActiveRecord, remova estas linhas.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # Usa test/fixtures para compartilhar fixtures com qualquer Minitest ou ferramenta remanescente
  config.fixture_paths = [
    Rails.root.join("spec/fixtures"),
    Rails.root.join("test/fixtures")
  ]

  # Se não estiver usando ActiveRecord, ou preferir não executar cada exemplo dentro
  # de uma transação, remova a linha abaixo ou atribua false em vez de true.
  config.use_transactional_fixtures = true

  # Descomente esta linha para desabilitar o suporte ao ActiveRecord completamente.
  # config.use_active_record = false

  # O RSpec Rails usa metadata para misturar comportamentos diferentes nos testes,
  # por exemplo habilitando `get` e `post` em request specs. Ex:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # Os tipos disponíveis estão documentados nas features, como em
  # https://rspec.info/features/7-1/rspec-rails
  #
  # Também é possível inferir esses comportamentos automaticamente pela localização, ex:
  # /spec/models aplica o mesmo comportamento que `type: :model`, mas este
  # comportamento é considerado legado e será removido em versões futuras.
  #
  # Para habilitar este comportamento, descomente a linha abaixo.
  config.infer_spec_type_from_file_location!

  # Filtra linhas de gems do Rails nos backtraces.
  config.filter_rails_from_backtrace!
  # Gems arbitrárias também podem ser filtradas via:
  # config.filter_gems_from_backtrace("nome da gem")
end
