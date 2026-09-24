# Este arquivo foi gerado pelo comando `rails generate rspec:install`. Por convenção, todos
# os specs ficam em um diretório `spec`, que o RSpec adiciona ao `$LOAD_PATH`.
# O arquivo `.rspec` gerado contém `--require spec_helper`, o que faz com que
# este arquivo seja sempre carregado, sem necessidade de require explícito nos arquivos.
#
# Como é sempre carregado, recomenda-se manter este arquivo o mais leve possível.
# Carregar dependências pesadas aqui aumenta o tempo de boot da suíte de testes em CADA
# execução, mesmo para um arquivo individual que pode não precisar de tudo isso. Em vez
# disso, considere criar um arquivo helper separado que carregue as dependências extras
# e faça require apenas nos specs que realmente precisam.
#
# Consulte https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # Configurações do rspec-expectations ficam aqui. É possível usar uma biblioteca
  # alternativa de asserção/expectation como wrong ou as asserções stdlib/minitest.
  config.expect_with :rspec do |expectations|
    # Esta opção será true por padrão no RSpec 4. Faz com que `description`
    # e `failure_message` de matchers customizados incluam texto dos métodos helper
    # definidos com `chain`, ex:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...em vez de:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Configurações do rspec-mocks ficam aqui. É possível usar uma biblioteca alternativa
  # de test doubles (como bogus ou mocha) alterando a opção `mock_with` aqui.
  config.mock_with :rspec do |mocks|
    # Impede que você faça mock ou stub de um método que não existe no objeto real.
    # Geralmente recomendado; será true por padrão no RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Esta opção será `:apply_to_host_groups` por padrão no RSpec 4 (sem como desabilitar —
  # a opção existe apenas para compatibilidade retroativa no RSpec 3). Faz com que
  # metadados de shared context sejam herdados pelo hash de metadados dos grupos e
  # exemplos hospedeiros, em vez de disparar auto-inclusão implícita em grupos com
  # metadados correspondentes.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # As configurações abaixo são sugeridas para proporcionar uma boa experiência inicial
  # com o RSpec, mas sinta-se à vontade para personalizar.
  #   # Permite limitar uma execução de spec a exemplos ou grupos individuais
  #   # marcados com a metadata `:focus`. Quando nada está marcado com `:focus`,
  #   # todos os exemplos são executados. O RSpec também fornece aliases para
  #   # `it`, `describe` e `context` que incluem a metadata `:focus`:
  #   # `fit`, `fdescribe` e `fcontext`, respectivamente.
  #   config.filter_run_when_matching :focus
  #
  #   # Permite que o RSpec persista algum estado entre execuções para suportar as
  #   # opções de CLI `--only-failures` e `--next-failure`. Recomenda-se configurar
  #   # o sistema de controle de versão para ignorar este arquivo.
  #   config.example_status_persistence_file_path = "spec/examples.txt"
  #
  #   # Limita a sintaxe disponível à sintaxe sem monkey patching, que é a recomendada.
  #   # Para mais detalhes, consulte:
  #   # https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  #   config.disable_monkey_patching!
  #
  #   # Muitos usuários do RSpec normalmente executam a suíte completa ou um arquivo
  #   # individual. É útil permitir saída mais detalhada ao executar um arquivo spec individual.
  #   if config.files_to_run.one?
  #     # Usa o formatter de documentação para saída detalhada,
  #     # a menos que um formatter já tenha sido configurado
  #     # (ex: via flag na linha de comando).
  #     config.default_formatter = "doc"
  #   end
  #
  #   # Exibe os 10 exemplos e grupos de exemplos mais lentos ao final
  #   # da execução dos specs, para identificar quais specs estão lentos.
  #   config.profile_examples = 10
  #
  #   # Executa specs em ordem aleatória para detectar dependências de ordem.
  #   # Se encontrar uma dependência de ordem e quiser depurá-la, pode fixar a
  #   # ordem fornecendo o seed, que é impresso após cada execução.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Inicializa a randomização global neste processo usando a opção CLI `--seed`.
  #   # Isso permite usar `--seed` para reproduzir deterministicamente falhas de
  #   # testes relacionadas à randomização, passando o mesmo valor `--seed`
  #   # que disparou a falha.
  #   Kernel.srand config.seed
end
