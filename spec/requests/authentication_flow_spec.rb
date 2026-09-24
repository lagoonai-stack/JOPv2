# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication flow", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "user registration" do
    it "user can register with username" do
      expect do
        post user_registration_path, params: {
          user: {
            username: "new_user",
            email: "new_user@example.com",
            password: "Password123456!",
            password_confirmation: "Password123456!"
          }
        }
      end.to change(User, :count).by(1)

      follow_redirect!
      expect(response).to have_http_status(:success)
      user = User.find_by(username: "new_user")
      expect(user).to be_present
      expect(response.body).to include("Signed in as").or include("confirmation").or include("confirm")
    end
  end

  describe "user sign in with remember me" do
    let(:user) { create(:user) }

    it "sets remember me cookie when option is enabled" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "Password123456!",
          remember_me: "1"
        }
      }

      expect(response).to redirect_to(root_path)
      expect(cookies["remember_user_token"]).to be_present
    end
  end

  describe "user sign in with plan" do
    let(:user_with_plan) { create(:user, subscription_plan: "pro", subscription_period_ends_at: 1.month.from_now) }

    it "redirects to chat_path" do
      post user_session_path, params: {
        user: {
          email: user_with_plan.email,
          password: "Password123456!"
        }
      }
      expect(response).to redirect_to(chat_path)
    end
  end
end
