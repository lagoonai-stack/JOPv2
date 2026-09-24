module ApplicationHelper
  # Retorna o nome do stylesheet específico da página (sem .css) para a action atual,
  # ou nil se não houver. Permite que cada página tenha seu próprio CSS sem afetar as outras.
  def page_specific_stylesheet
    name = page_specific_stylesheet_name
    return nil if name.blank?

    path = Rails.root.join("app/assets/stylesheets", "#{name}.css")
    File.exist?(path) ? name : nil
  end

  def page_specific_stylesheet_name
    # Para registrations, create (cadastro com falha) renderiza :new e update (edição com falha)
    # renderiza :edit — selecionamos o stylesheet pelo template renderizado, não pela action.
    case [controller_name, action_name]
    when %w[home index] then "home"
    when %w[sessions new] then "sign_in"
    when %w[registrations new], %w[registrations create] then "sign_up"
    when %w[registrations edit], %w[registrations update] then "edit_account"
    when %w[chat show] then "chat"
    end
  end
end
