# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :admin_users, **ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  if Rails.env.development? && ENV["IS_DOCKER"] == "true"
    begin
      require "letter_opener_web"
      mount LetterOpenerWeb::Engine, at: "/letter_opener"
    rescue LoadError
      # letter_opener_web not in image (e.g. production build)
    end
  end

  devise_for :users, skip: %i[passwords unlocks registrations]
  devise_scope :user do
    get "users/sign_up", to: "devise/registrations#new", as: :new_user_registration
    post "users", to: "devise/registrations#create", as: :user_registration
    get "users/edit", to: "devise/registrations#edit", as: :edit_user_registration
    patch "users", to: "devise/registrations#update"
    put "users", to: "devise/registrations#update"
    delete "users", to: "devise/registrations#destroy"
    get "users/cancel", to: "devise/registrations#cancel", as: :cancel_user_registration
  end

  # Checkout Stripe (usuários autenticados)
  post "checkout/create", to: "checkout#create", as: :checkout_create
  get "checkout/success", to: "checkout#success", as: :checkout_success
  get "checkout/cancel", to: "checkout#cancel", as: :checkout_cancel

  # Webhook Stripe (sem CSRF — assinatura verificada no controller)
  post "webhooks/stripe", to: "webhooks#stripe"

  # Claude chat (logged-in users only)
  get  "chat",         to: "chat#show", as: :chat
  post "chat",         to: "chat#create"
  post "chat/finish",  to: "chat#finish_prompt", as: :finish_chat

  # Video pipeline — scoped under each conversation for ownership enforcement
  # All actions in VideoController verify the conversation belongs to current_user.
  scope "conversations/:conversation_id/video", as: :conversation_video do
    post "preview",  to: "video#request_preview", as: :preview
    post "approve",  to: "video#approve",          as: :approve
    get  "status",   to: "video#status",           as: :status
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # Captura rotas não mapeadas e renderiza 404 (deve ser a última)
  match "*path",
        to: "errors#not_found",
        via: :all,
        constraints: ->(req) { !req.path.start_with?("/assets", "/packs", "/rails") }
end
