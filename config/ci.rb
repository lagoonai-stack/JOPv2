# Execute com bin/ci

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap vulnerability audit", "bin/importmap audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Tests: Rails", "bin/rails test"
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"

  # Opcional: Executar testes de sistema
  # step "Tests: System", "bin/rails test:system"

  # Opcional: define um status verde no GitHub para desbloquear o merge do PR.
  # Requer a CLI `gh` e `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: Tudo certo. Pronto para merge e deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI falhou. Não faça merge nem deploy.", "Corrija os problemas e tente novamente."
  # end
end
