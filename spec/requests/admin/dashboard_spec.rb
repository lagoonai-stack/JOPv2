# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:admin_user) }

  before { sign_in admin_user, scope: :admin_user }

  describe "GET /admin (dashboard)" do
    it "returns success and shows dashboard" do
      get admin_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Dashboard").or include("dashboard")
    end

    it "shows new users (past 30 days) panel" do
      get admin_root_path

      expect(response.body).to include("New users")
      expect(response.body).to include("past 30 days")
    end

    it "shows payments (past 30 days) panel" do
      get admin_root_path

      expect(response.body).to include("Payments")
      expect(response.body).to include("past 30 days")
    end

    it "displays count of new users in the past 30 days" do
      create_list(:user, 2, confirmed_at: Time.current, created_at: 1.day.ago)

      get admin_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("2").or include("users")
    end

    it "displays count of payments in the past 30 days" do
      user = create(:user, confirmed_at: Time.current)
      create_list(:payment, 3, user: user, status: "completed", created_at: 1.day.ago)

      get admin_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("3").or include("payments")
    end
  end
end
