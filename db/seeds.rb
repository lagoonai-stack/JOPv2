# Este arquivo deve garantir a existência dos registros necessários para rodar a aplicação
# em todos os ambientes (production, development, test). O código aqui deve ser idempotente
# para que possa ser executado a qualquer momento em qualquer ambiente.
# Os dados podem ser carregados com bin/rails db:seed (ou junto com o banco em db:setup).
#
# Exemplo:
#
#   ["Ação", "Comédia", "Drama", "Terror"].each do |genero|
#     GeneroFilme.find_or_create_by!(nome: genero)
#   end
if Rails.env.development?
  default_password = "Abcde,12345"
  plans = %w[starter pro]

  AdminUser.find_or_create_by!(email: "admin@gmail.com") do |admin|
    admin.password = default_password
    admin.password_confirmation = default_password
  end

  user = User.find_or_create_by!(email: "user@gmail.com") do |user|
    user.username = "user_with_plan"
    user.subscription_plan = "starter"
    user.subscription_period_started_at = 1.day.ago
    user.subscription_period_ends_at = 1.month.from_now
    user.password = default_password
    user.password_confirmation = default_password
    user.confirmed_at = Time.current
    user.confirmation_sent_at = Time.current
    user.confirmation_token = Devise.friendly_token[0, 20]
  end


  payments = []
  10.times do
    payments << {
      amount_cents: rand(2000..9999),
      currency: "brl",
      plan: plans.sample,
      status: "pending"
    }
  end

  user.payments.create!(payments)
end
