# frozen_string_literal: true

# Assumindo que este arquivo ainda não foi modificado, cada opção de configuração abaixo
# está definida com seu valor padrão. Note que algumas estão comentadas e outras não:
# as linhas descomentadas visam proteger sua configuração de quebras em upgrades
# (ou seja, caso versões futuras do Devise alterem os valores padrão dessas opções).
#
# Use este hook para configurar o mailer do Devise, hooks do Warden etc.
# Muitas dessas opções também podem ser definidas diretamente no model.
Devise.setup do |config|
  # Chave secreta usada pelo Devise para gerar tokens aleatórios. Alterar esta chave
  # invalidará todos os tokens de confirmação, reset de senha e desbloqueio existentes.
  # Por padrão, o Devise usa o `secret_key_base` como `secret_key`.
  # É possível alterá-la abaixo e usar uma chave própria.
  # config.secret_key = '7f2e282b77cfc81886ff6adba8f8d0ff9fd168deff2f9a42178295080afc4fb053257f69f045197cded26975069f2c9d0214276aa2027d1080b4480859539d70'
  # rubocop:enable Layout/LineLength

  # ==> Configuração de Controller
  # Define a classe pai dos controllers do Devise.
  # config.parent_controller = 'DeviseController'

  # ==> Configuração de Mailer
  # Define o endereço de e-mail exibido no Devise::Mailer.
  # Será sobrescrito se você usar sua própria classe de mailer com o parâmetro "from" padrão.
  config.mailer_sender = ENV.fetch("DEVISE_MAILER_SENDER", "no-reply@example.com")

  # Define a classe responsável por enviar e-mails.
  # config.mailer = 'Devise::Mailer'

  # Define a classe pai responsável por enviar e-mails.
  # config.parent_mailer = 'ActionMailer::Base'

  # ==> Configuração de ORM
  # Carrega e configura o ORM. Suporta :active_record (padrão) e
  # :mongoid (bson_ext recomendado) por padrão. Outros ORMs podem
  # estar disponíveis como gems adicionais.
  require "devise/orm/active_record"

  # ==> Configuração para qualquer mecanismo de autenticação
  # Define quais chaves são usadas ao autenticar um usuário. O padrão é apenas :email.
  # É possível configurar para usar [:username, :subdomain] — nesse caso, ambos os parâmetros
  # são necessários para autenticar. Lembre-se que esses parâmetros são usados apenas na
  # autenticação, não na recuperação da sessão. Para permissões, implemente em um before filter.
  # Também é possível fornecer um hash onde o valor é um booleano que determina se a
  # autenticação deve ser abortada quando o valor não está presente.
  # config.authentication_keys = [:email]

  # Define parâmetros do objeto request usados na autenticação. Cada entrada deve ser
  # um método de request que será automaticamente passado ao find_for_authentication
  # e considerado na busca do model. Por exemplo, se :request_keys incluir [:subdomain],
  # :subdomain será usado na autenticação. As mesmas considerações de authentication_keys
  # se aplicam a request_keys.
  # config.request_keys = []

  # Define quais chaves de autenticação devem ser case-insensitive.
  # Essas chaves serão convertidas para minúsculas ao criar ou modificar um usuário
  # e ao autenticar ou buscar um usuário. Padrão: :email.
  config.case_insensitive_keys = [ :email ]

  # Define quais chaves de autenticação devem ter espaços removidos.
  # Essas chaves terão os espaços antes e depois removidos ao criar ou modificar um usuário
  # e ao autenticar ou buscar um usuário. Padrão: :email.
  config.strip_whitespace_keys = [ :email ]

  # Indica se a autenticação via request.params está habilitada. Padrão: true.
  # Pode ser definido como um array para habilitar autenticação por params apenas para
  # certas estratégias. Ex: `config.params_authenticatable = [:database]` habilita
  # apenas para autenticação por banco de dados (email + senha).
  # config.params_authenticatable = true

  # Indica se a autenticação via HTTP Auth está habilitada. Padrão: false.
  # Pode ser definido como um array para habilitar HTTP Auth apenas para certas estratégias.
  # Ex: `config.http_authenticatable = [:database]` habilita apenas para autenticação por banco.
  # Para apps API-only com autenticação "out-of-the-box", provavelmente você vai querer
  # habilitar com :database, a menos que use uma estratégia personalizada.
  # Estratégias suportadas:
  # :database = Suporte a autenticação básica com chave de autenticação + senha
  # config.http_authenticatable = false

  # Se o código 401 deve ser retornado para requisições AJAX. Padrão: true.
  # config.http_authenticatable_on_xhr = true

  # O realm usado em HTTP Basic Authentication. Padrão: 'Application'.
  # config.http_authentication_realm = 'Application'

  # Faz com que confirmação, recuperação de senha e outros fluxos se comportem
  # da mesma forma independentemente de o e-mail fornecido estar correto ou não.
  # Não afeta :registerable.
  config.paranoid = true

  # Por padrão, o Devise armazena o usuário na sessão. É possível pular o armazenamento
  # para estratégias específicas usando esta opção.
  # Note que se você pular o armazenamento para todos os caminhos de autenticação,
  # convém desabilitar a geração de rotas para o sessions controller do Devise
  # passando skip: :sessions para `devise_for` em config/routes.rb.
  config.skip_session_storage = [ :http_auth ]

  # Por padrão, o Devise limpa o token CSRF na autenticação para evitar ataques de
  # fixação de token CSRF. Isso significa que, ao usar requisições AJAX para sign in
  # e sign up, é necessário obter um novo token CSRF do servidor.
  # Desabilite esta opção por sua conta e risco.
  # config.clean_up_csrf_token_on_authentication = true

  # Quando false, o Devise não tentará recarregar as rotas no eager load.
  # Isso pode reduzir o tempo de boot, mas se sua aplicação exigir que os mappings
  # do Devise sejam carregados no boot, a aplicação não inicializará corretamente.
  # config.reload_routes = true

  # ==> Configuração para :database_authenticatable
  # Para bcrypt, este é o custo do hash de senha e padrão é 12. Para outros algoritmos,
  # define quantas vezes a senha será hasheada. O número de stretches usados para gerar
  # o hash é armazenado junto com ele, permitindo alterá-lo sem invalidar senhas existentes.
  #
  # Limitar os stretches a 1 nos testes aumentará dramaticamente a performance da suíte.
  # Porém, é FORTEMENTE RECOMENDADO não usar valor menor que 10 em outros ambientes.
  # Note que, para bcrypt (o padrão), o custo cresce exponencialmente com os stretches
  # (ex: um valor de 20 já é extremamente lento: ~60 segundos por cálculo).
  config.stretches = Rails.env.test? ? 1 : 12

  # Define um pepper para gerar o hash da senha.
  # rubocop:disable Layout/LineLength
  # config.pepper = 'f201c853fcbd4def1944bb1782523dacd14b937f774e9071c3122c966876b633478844453d3cdd9478452cd55d5641d1829890b4eebfa5d9d6e654f7d12a0fff'
  # rubocop:enable Layout/LineLength

  # Alerta o endereço original quando o e-mail é alterado — detecta tomada de conta precocemente.
  config.send_email_changed_notification = true

  # Alerta o usuário quando sua senha é alterada — detecta resets não autorizados.
  config.send_password_change_notification = true

  # ==> Configuração para :confirmable
  # Período em que o usuário pode acessar o site sem confirmar a conta. Ex: se definido
  # como 2.days, o usuário pode acessar por dois dias sem confirmar — bloqueado no terceiro.
  # Defina como nil para permitir acesso sem confirmação.
  # Padrão: 0.days — o usuário não pode acessar sem confirmar a conta.
  config.allow_unconfirmed_access_for = 0.days

  # Período em que o usuário pode confirmar a conta antes do token se tornar inválido.
  # Ex: se definido como 3.days, o usuário pode confirmar dentro de 3 dias após o envio,
  # mas no quarto dia o token não é mais válido.
  # Padrão: nil — sem restrição de tempo para confirmar.
  config.confirm_within = 1.day

  # Se true, exige que qualquer alteração de e-mail seja confirmada (da mesma forma que
  # a confirmação inicial) para ser aplicada. Requer o campo unconfirmed_email no banco.
  # Até ser confirmado, o novo e-mail fica em unconfirmed_email e é copiado para email
  # na confirmação bem-sucedida. Usado com `send_email_changed_notification`, a notificação
  # é enviada ao e-mail original quando a mudança é solicitada, não quando confirmada.
  config.reconfirmable = true

  # Define qual chave será usada ao confirmar uma conta.
  config.confirmation_keys = [:email]

  # ==> Configuração para :rememberable
  # Tempo em que o usuário será lembrado sem precisar inserir as credenciais novamente.
  config.remember_for = 1.month

  # Invalida todos os tokens de remember me quando o usuário faz logout.
  config.expire_all_remember_me_on_sign_out = true

  # Se true, estende o período de remember me quando o usuário é lembrado via cookie.
  # config.extend_remember_period = false

  # Opções passadas ao cookie criado. Ex: secure: true para forçar cookies somente SSL.
  config.rememberable_options = {
    secure: Rails.env.production?,
    httponly: true,
    same_site: :lax
  }

  # ==> Configuração para :validatable
  # Faixa de comprimento da senha.
  config.password_length = 8..128

  # Regex de e-mail usado para validar o formato. Verifica simplesmente que existe
  # um (e somente um) @ na string. Serve principalmente para feedback ao usuário,
  # não para validar a validade real do e-mail.
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuração para :timeoutable
  # Tempo de inatividade após o qual a sessão do usuário expira. Após esse tempo
  # o usuário precisará inserir as credenciais novamente. Padrão: 30 minutos.
  # config.timeout_in = 30.minutes

  # ==> Configuração para :lockable
  # Define qual estratégia será usada para bloquear uma conta.
  # :failed_attempts = Bloqueia a conta após N tentativas falhas de login.
  # :none            = Sem estratégia de bloqueio. Você deve implementar o bloqueio.
  # config.lock_strategy = :failed_attempts

  # Define qual chave será usada ao bloquear e desbloquear uma conta.
  # config.unlock_keys = [:email]

  # Define qual estratégia será usada para desbloquear uma conta.
  # :email = Envia um link de desbloqueio para o e-mail do usuário
  # :time  = Reabilita o login após um determinado tempo (veja :unlock_in abaixo)
  # :both  = Habilita ambas as estratégias
  # :none  = Sem estratégia de desbloqueio. Você deve implementar o desbloqueio.
  # config.unlock_strategy = :both

  # Número de tentativas de autenticação antes de bloquear a conta quando
  # lock_strategy é :failed_attempts.
  # config.maximum_attempts = 20

  # Intervalo de tempo para desbloquear a conta quando :time está habilitado como unlock_strategy.
  # config.unlock_in = 1.hour

  # Avisa o usuário na última tentativa antes de a conta ser bloqueada.
  # config.last_attempt_warning = true

  # ==> Configuração para :recoverable
  #
  # Define qual chave será usada ao recuperar a senha de uma conta.
  # config.reset_password_keys = [:email]

  # Intervalo de tempo em que a senha pode ser redefinida com um token de reset.
  # Não defina um intervalo muito pequeno ou os usuários não terão tempo de redefinir.
  config.reset_password_within = 6.hours

  # Quando false, não loga o usuário automaticamente após o reset de senha.
  # Padrão: true — o usuário é logado automaticamente após o reset.
  # config.sign_in_after_reset_password = true

  # ==> Configuração para :encryptable
  # Permite usar outro algoritmo de hash ou criptografia além do bcrypt (padrão).
  # É possível usar :sha1, :sha512 ou algoritmos de outras ferramentas de autenticação como
  # :clearance_sha1, :authlogic_sha512 (defina stretches como 20 para comportamento padrão)
  # e :restful_authentication_sha1 (defina stretches como 10 e copie REST_AUTH_SITE_KEY para pepper).
  #
  # Inclua a gem `devise-encryptable` ao usar qualquer coisa diferente de bcrypt.
  # config.encryptor = :sha512

  # ==> Configuração de Scopes
  # Ativa views com escopo. Antes de renderizar "sessions/new", verificará primeiro
  # "users/sessions/new". Desabilitado por padrão pois é mais lento quando se usam
  # apenas as views padrão.
  config.scoped_views = true

  # Define o scope padrão fornecido ao Warden. Por padrão é o primeiro role do Devise
  # declarado nas rotas (geralmente :user).
  # config.default_scope = :user

  # Defina como false se quiser que /users/sign_out faça logout apenas do scope atual.
  # Por padrão, o Devise faz logout de todos os scopes.
  # config.sign_out_all_scopes = true

  # ==> Configuração de Navegação
  # Lista os formatos que devem ser tratados como navegacionais. Formatos como
  # :html devem redirecionar para a página de login quando o usuário não tem acesso,
  # mas formatos como :xml ou :json devem retornar 401.
  #
  # Se houver formatos extras de navegação, como :iphone ou :mobile,
  # adicione-os à lista de formatos navegacionais.
  #
  # O "*/*" abaixo é necessário para corresponder a requisições do Internet Explorer.
  config.navigational_formats = [ "*/*", :html, :turbo_stream ]

  # Método HTTP padrão usado para fazer logout de um resource. Padrão: :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  # Adiciona um novo provider OmniAuth. Consulte a wiki para mais informações sobre
  # configuração nos models e hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'

  # ==> Configuração do Warden
  # Para usar outras estratégias não suportadas pelo Devise, ou para alterar o
  # failure app, configure dentro do bloco config.warden.
  #
  # config.warden do |warden_config|
  #   warden_config.intercept_401 = false
  #   warden_config.default_strategies(scope: :user).unshift :some_external_strategy
  # end

  # ==> Configurações para engines montáveis
  # Ao usar o Devise dentro de uma engine (ex: `MyEngine`) montável, há configurações
  # adicionais a considerar. As seguintes opções estão disponíveis, assumindo que a
  # engine está montada como:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # O router que invocou `devise_for` no exemplo acima seria:
  # config.router_name = :my_engine
  #
  # Ao usar OmniAuth, o Devise não consegue definir o caminho automaticamente,
  # então você precisa fazê-lo manualmente. Para o scope de usuários, seria:
  # config.omniauth_path_prefix = '/my_engine/users/auth'

  # ==> Configuração Hotwire/Turbo
  # Ao usar o Devise com Hotwire/Turbo, os status HTTP para respostas de erro
  # e alguns redirects devem corresponder ao seguinte. O padrão no Devise para apps
  # existentes é `200 OK` e `302 Found` respectivamente, mas novas apps são geradas
  # com esses novos padrões compatíveis com o comportamento do Hotwire/Turbo.
  # Nota: Esses podem se tornar o novo padrão em versões futuras do Devise.
  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other

  # ==> Configuração para :registerable

  # Quando false, não loga o usuário automaticamente após a alteração de senha.
  # Padrão: true — o usuário é logado automaticamente após alterar a senha.
  # config.sign_in_after_change_password = true
end
