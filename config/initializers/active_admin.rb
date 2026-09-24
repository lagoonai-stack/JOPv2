ActiveAdmin.setup do |config|
  # == Título do Site
  #
  # Define o título exibido no layout principal
  # em cada página do Active Admin.
  #
  config.site_title = "One Prompt"

  # Define a URL do link do título. Por exemplo, para levar
  # os usuários ao site principal. Padrão: sem link.
  #
  # config.site_title_link = "/"

  # Define uma imagem opcional para exibir no cabeçalho
  # no lugar do texto (substitui :site_title).
  #
  # Nota: Use uma imagem de ~21px de altura para caber no cabeçalho.
  #
  # config.site_title_image = "logo.png"

  # == Caminhos de Carregamento
  #
  # Por padrão os arquivos do Active Admin ficam em app/admin/.
  # É possível alterar esse diretório.
  #
  # ex:
  #   config.load_paths = [File.join(Rails.root, 'app', 'ui')]
  #
  # Também é possível carregar mais diretórios.
  # Útil ao usar namespaces com entidades que não são o AdminUser principal.
  #
  # ex:
  #   config.load_paths = [
  #     File.join(Rails.root, 'app', 'admin'),
  #     File.join(Rails.root, 'app', 'cashier')
  #   ]

  # == Namespace Padrão
  #
  # Define o namespace padrão ao qual cada resource de administração
  # será adicionado.
  #
  # ex:
  #   config.default_namespace = :hello_world
  #
  # Isso criará resources no módulo HelloWorld e
  # fará namespace das rotas para /hello_world/*
  #
  # Para não usar nenhum namespace por padrão:
  #   config.default_namespace = false
  #
  # Padrão:
  # config.default_namespace = :admin
  #
  # É possível personalizar as configurações de cada namespace usando
  # um bloco de namespace. Por exemplo, para alterar o título do site
  # dentro de um namespace:
  #
  #   config.namespace :admin do |admin|
  #     admin.site_title = "Título Admin Customizado"
  #   end
  #
  # Isso alterará SOMENTE o título da seção admin. Os outros
  # namespaces continuarão usando a configuração principal de "site_title".

  # == Autenticação de Usuário
  #
  # O Active Admin chamará automaticamente um método de autenticação
  # em um before filter de todas as actions dos controllers para
  # garantir que haja um admin logado.
  #
  # Esta configuração altera o método que o Active Admin chama
  # dentro do application controller.
  config.authentication_method = :authenticate_admin_user!

  # == Autorização de Usuário
  #
  # O Active Admin chamará automaticamente um método de autorização
  # em um before filter de todas as actions dos controllers para
  # garantir que o usuário tenha os direitos adequados. É possível usar
  # CanCanAdapter ou criar o seu próprio. Consulte a documentação.
  # config.authorization_adapter = ActiveAdmin::CanCanAdapter

  # Para usar Pundit em vez de outras soluções, passe aqui o nome
  # da classe de policy padrão. Essa policy será usada sempre que
  # o Pundit não encontrar uma policy adequada.
  # config.pundit_default_policy = "MyDefaultPunditPolicy"

  # Para manter um conjunto separado de policies Pundit para recursos admin,
  # defina aqui um namespace que o Pundit usará ao buscar a policy do resource.
  # config.pundit_policy_namespace = :admin

  # É possível personalizar o nome da classe Ability do CanCan aqui.
  # config.cancan_ability_class = "Ability"

  # É possível especificar um método a ser chamado em acesso não autorizado.
  # Isso é necessário para evitar loop de redirect que ocorre porque,
  # por padrão, o usuário é redirecionado ao Dashboard. Se o usuário
  # não tiver acesso ao Dashboard, ficará em loop infinito.
  # O método fornecido aqui deve ser definido em application_controller.rb.
  # config.on_unauthorized_access = :access_denied

  # == Usuário Atual
  #
  # O Active Admin associará as ações ao usuário atual
  # que as está executando.
  #
  # Esta configuração altera o método que o Active Admin chama
  # (dentro do application controller) para retornar o usuário logado.
  config.current_user_method = :current_admin_user

  # == Logout
  #
  # O Active Admin exibe um link de logout em cada tela. Estas
  # configurações definem o local e o método usado pelo link.
  #
  # Esta configuração altera o caminho para o qual o link aponta. Se for
  # uma string, ela é usada diretamente como caminho. Se for um Symbol,
  # o método será chamado para retornar o caminho.
  #
  # Padrão:
  config.logout_link_path = :destroy_admin_user_session_path

  # Esta configuração altera o método HTTP usado ao renderizar o link.
  # Por exemplo: :get, :delete, :put, etc.
  #
  # Padrão:
  # config.logout_link_method = :get

  # == Root
  #
  # Define a action a ser chamada para o caminho raiz. É possível definir
  # roots diferentes para cada namespace.
  #
  # Padrão:
  # config.root_to = 'dashboard#index'

  # == Comentários do Admin (desabilitado — tabela removida)
  #
  # Comentários permitiam que admins adicionassem notas nos resources; não usado nesta app.
  config.comments = false
  #
  # É possível alterar o nome com que os comentários são registrados:
  # config.comments_registration_name = 'AdminComment'
  #
  # É possível alterar a ordenação dos comentários e a coluna usada para ordenar:
  # config.comments_order = 'created_at ASC'
  #
  # É possível desabilitar o item de menu da página de índice de comentários:
  # config.comments_menu = false
  #
  # É possível personalizar o menu de comentários:
  # config.comments_menu = { parent: 'Admin', priority: 1 }

  # == Ações em Lote
  #
  # Habilita e desabilita Ações em Lote
  #
  config.batch_actions = true

  # == Filtros de Controller
  #
  # É possível adicionar filtros before, after e around a todos os resources
  # e páginas do Active Admin a partir daqui.
  #
  # config.before_action :do_something_awesome

  # == Filtros de Atributos
  #
  # É possível excluir atributos de model potencialmente sensíveis de serem exibidos,
  # adicionados a formulários ou exportados por padrão pelo ActiveAdmin.
  #
  config.filter_attributes = %i[encrypted_password password password_confirmation]

  # == Formato de Data/Hora
  #
  # Define o formato de localização para exibir datas e horas.
  # Para entender como localizar sua aplicação com I18n, leia:
  # https://guides.rubyonrails.org/i18n.html
  #
  # Execute `bin/rails runner 'puts I18n.t("date.formats")'` para ver os
  # formatos disponíveis na sua aplicação.
  #
  config.localize_format = :long

  # == Favicon
  #
  # config.favicon = 'favicon.ico'

  # == Meta Tags
  #
  # Adiciona meta tags extras ao elemento head das páginas do active admin.
  #
  # Tags para todas as páginas de usuários logados:
  #   config.meta_tags = { author: 'Minha Empresa' }

  # Por padrão, páginas de cadastro/login/recuperação de senha são excluídas
  # dos resultados de mecanismos de busca via meta tag robots.
  # É possível redefinir o hash de meta tags incluídas nas páginas deslogadas:
  #   config.meta_tags_for_logged_out_pages = {}

  # == Removendo Breadcrumbs
  #
  # Breadcrumbs estão habilitados por padrão. É possível personalizá-los por resource
  # individual ou desabilitá-los globalmente aqui.
  #
  # config.breadcrumb = false

  # == Checkbox "Criar outro"
  #
  # O checkbox "Criar outro" está desabilitado por padrão. É possível personalizá-lo
  # por resource individual ou habilitá-lo globalmente aqui.
  #
  # config.create_another = true

  # == Registrar Stylesheets e Javascripts
  #
  # Recomendamos usar o layout padrão do Active Admin e carregar seus próprios
  # stylesheets/javascripts para personalizar a aparência.
  #
  # Para carregar um stylesheet:
  #   config.register_stylesheet 'my_stylesheet.css'
  #
  # É possível passar um hash de opções para mais controle (repassado ao stylesheet_link_tag()):
  #   config.register_stylesheet 'my_print_stylesheet.css', media: :print
  #
  # Para carregar um arquivo javascript:
  #   config.register_javascript 'my_javascript.js'

  # == Opções de CSV
  #
  # Define o separador do CSV
  # config.csv_options = { col_sep: ';' }
  #
  # Força o uso de aspas
  # config.csv_options = { force_quotes: true }

  # == Sistema de Menu
  #
  # É possível adicionar um menu de navegação à sua aplicação ou configurar um menu existente.
  #
  # Para alterar a navegação utilitária padrão e exibir um link para o seu site e um botão de logout:
  #
  #   config.namespace :admin do |admin|
  #     admin.build_menu :utility_navigation do |menu|
  #       menu.add label: "Meu Site", url: "http://www.meusite.com", html_options: { target: :blank }
  #       admin.add_logout_button_to_menu menu
  #     end
  #   end
  #
  # Para adicionar um item estático ao menu padrão:
  #
  #   config.namespace :admin do |admin|
  #     admin.build_menu :default do |menu|
  #       menu.add label: "Meu Site", url: "http://www.meusite.com", html_options: { target: "_blank" }
  #     end
  #   end

  # == Links de Download
  #
  # É possível desabilitar links de download nas páginas de listagem de resources,
  # ou personalizar os formatos exibidos por namespace/globalmente.
  #
  # Para desabilitar/personalizar no namespace :admin:
  #
  #   config.namespace :admin do |admin|
  #
  #     # Desabilita os links completamente
  #     admin.download_links = false
  #
  #     # Exibe apenas XML e PDF
  #     admin.download_links = [:xml, :pdf]
  #
  #     # Habilita/desabilita via bloco (ex: com cancan)
  #     admin.download_links = proc { can?(:view_download_links) }
  #
  #   end

  # == Paginação
  #
  # A paginação está habilitada por padrão para todos os resources.
  # É possível controlar a quantidade padrão por página para todos os resources aqui.
  #
  # config.default_per_page = 30
  #
  # É possível controlar também a quantidade máxima por página.
  #
  # config.max_per_page = 10_000

  # == Filtros
  #
  # Por padrão a tela de índice inclui uma barra lateral "Filtros" à direita
  # com um filtro para cada atributo do model registrado.
  # É possível habilitá-los ou desabilitá-los para todos os resources aqui.
  #
  # config.filters = true
  #
  # Por padrão os filtros incluem associações em um select, o que significa que
  # todos os registros serão carregados para cada associação
  # (até o valor de config.maximum_association_filter_arity).
  # É possível habilitar ou desabilitar a inclusão desses filtros por padrão aqui.
  #
  # config.include_default_association_filters = true

  # config.maximum_association_filter_arity = 256 # o padrão :unlimited mudará para 256 em versão futura
  # config.filter_columns_for_large_association = [
  #    :display_name,
  #    :full_name,
  #    :name,
  #    :username,
  #    :login,
  #    :title,
  #    :email,
  #  ]
  # config.filter_method_for_large_association = '_start'

  # == Head
  #
  # É possível adicionar conteúdo ao head do site (ex: analytics).
  # Certifique-se de passar apenas conteúdo confiável.
  #
  # Chart.js, adaptador de data (necessário para escala de tempo em line_chart) e Chartkick
  config.head = <<~HTML.html_safe
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3.0.0/dist/chartjs-adapter-date-fns.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartkick@5.0.1/dist/chartkick.min.js"></script>
  HTML

  # == Rodapé
  #
  # Por padrão o rodapé exibe a versão atual do Active Admin.
  # É possível substituir o conteúdo do rodapé aqui.
  #
  # config.footer = 'meu texto de rodapé personalizado'

  # == Ordenação
  #
  # Por padrão ActiveAdmin::OrderClause é usado para a lógica de ordenação.
  # É possível herdar com uma classe própria e injetá-la para todos os resources.
  #
  # config.order_clause = MyOrderClause

  # == Webpacker
  #
  # Por padrão o Active Admin usa o asset pipeline do Sprockets.
  # É possível mudar para usar o Webpacker aqui.
  #
  # config.use_webpacker = true
end
