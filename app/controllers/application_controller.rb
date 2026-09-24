# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Permite apenas navegadores modernos com suporte a webp, web push, badges, import maps, CSS nesting e CSS :has.
  allow_browser versions: :modern

  # Alterações no importmap invalidam o etag das respostas HTML
  stale_when_importmap_changes

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def set_locale
    requested = params[:locale] || session[:locale]
    I18n.locale = session[:locale] = valid_locale?(requested) ? requested.to_sym : I18n.default_locale
    session[:locale] = I18n.locale

    current_user.update!(locale: I18n.locale) if should_update_current_user_locale?
  end

  def default_url_options
    opts = {}
    opts[:locale] = I18n.locale if I18n.locale != I18n.default_locale
    opts
  end

  def valid_locale?(locale)
    locale.present? && I18n.available_locales.include?(locale.to_sym)
  end

  def should_update_current_user_locale?
    user_signed_in? && current_user.locale != I18n.locale.to_s
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.plan_config.present?
      chat_path
    else
      super
    end
  end

  def after_sign_up_path_for(_resource)
    root_path
  end
end
