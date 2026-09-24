# Reinicie o servidor após modificar este arquivo.
#
# CSP ativa em modo report-only: violações são registradas nos logs mas nada é bloqueado.
# Isso nos permite auditar a política antes de enforçá-la em produção.
# Quando as violações pararem de aparecer nos logs, remova `content_security_policy_report_only`
# para ativar o enforcement completo.
#
# Origens principais permitidas:
#   - Stripe: js.stripe.com (scripts), hooks.stripe.com + js.stripe.com (frames)
#   - Turbo/Stimulus: scripts da mesma origem carregados via importmap
#   - ActiveAdmin: requer unsafe-inline para estilos (Arbre gera estilos inline)

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, "blob:"
    policy.object_src  :none
    policy.script_src  :self, "https://js.stripe.com"
    policy.style_src   :self, :https, :unsafe_inline # ActiveAdmin requer unsafe-inline
    policy.connect_src :self, "https://api.stripe.com"
    policy.frame_src   "https://js.stripe.com", "https://hooks.stripe.com"
    policy.form_action :self
    policy.base_uri    :self
    policy.worker_src  :none
  end

  # Nonce para scripts carregados via importmap e chamadas explícitas a javascript_tag.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report-only: registra violações sem bloquear — seguro para o primeiro deploy em produção.
  # Remova esta linha para enforçar a política quando os logs estiverem limpos.
  config.content_security_policy_report_only = true
end
