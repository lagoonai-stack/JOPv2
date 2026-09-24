namespace :users do
  desc "Atribui plano gratuito a usuários sem plano"
  task assign_free_plan: :environment do
    count = 0
    User.where(subscription_plan: [nil, ""]).find_each do |user|
      user.send(:assign_free_plan) # Usa o método privado que criamos
      count += 1
      puts "Assigned free plan to user ##{user.id} (#{user.email})"
    rescue StandardError => e
      puts "Error updating user ##{user.id}: #{e.message}"
    end
    puts "Done! #{count} users updated."
  end
end
