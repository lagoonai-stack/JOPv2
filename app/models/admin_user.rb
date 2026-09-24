class AdminUser < ApplicationRecord
  # Módulos Devise incluídos. Outros disponíveis:
  # :confirmable, :lockable, :timeoutable, :trackable e :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at email id remember_created_at reset_password_sent_at updated_at]
  end
end
