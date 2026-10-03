# frozen_string_literal: true

namespace :users do
  desc "Atribui o plano ilimitado (interno) a um usuário: rake users:assign_unlimited_plan EMAIL=alguem@exemplo.com"
  task assign_unlimited_plan: :environment do
    email = ENV["EMAIL"].to_s.strip.downcase
    abort "Informe o email: rake users:assign_unlimited_plan EMAIL=alguem@exemplo.com" if email.blank?

    user = User.find_by("lower(email) = ?", email)
    abort "Usuário não encontrado para o email #{email}" if user.nil?

    user.update!(
      subscription_plan: "unlimited",
      subscription_period_started_at: Time.current,
      subscription_period_ends_at: 100.years.from_now
    )

    puts "Plano ilimitado atribuído ao usuário ##{user.id} (#{user.email})."
    puts "Limite do período: #{user.tokens_limit_this_period} tokens · usados: #{user.tokens_used_this_period}"
  end
end
