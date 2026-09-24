# frozen_string_literal: true

ActiveAdmin.register Payment do
  actions :index, :show

  index do
    id_column
    column :user do |p|
      if p.user
        link_to p.user.email, admin_user_path(p.user)
      else
        span "-", class: "empty"
      end
    end
    column :plan
    column :amount_cents do |p|
      number_to_currency(p.amount_cents / 100.0, unit: "R$ ", separator: ",", delimiter: ".", format: "%u %n")
    end
    column :currency do |p|
      p.currency.upcase
    end
    column :status
    column :created_at
  end

  filter :user
  filter :plan, as: :select, collection: %w[starter pro]
  filter :status, as: :select, collection: %w[pending completed failed refunded]
  filter :currency, as: :select, collection: -> { Payment.distinct.pluck(:currency).map(&:upcase) }
  filter :created_at
end
