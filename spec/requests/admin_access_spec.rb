# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin access", type: :request do
  let(:admin_user) { create(:admin_user) }

  describe "GET /admin" do
    context "when not signed in as admin" do
      it "redirects guest users to admin login" do
        get admin_root_path

        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("/admin/login")
      end
    end

    context "when signed in as admin" do
      before { sign_in admin_user, scope: :admin_user }

      it "allows admin users into admin area" do
        get admin_root_path

        expect(response).to have_http_status(:success)
      end

      it "loads admin users index" do
        get admin_users_path

        expect(response).to have_http_status(:success)
      end

      it "loads admin admin_users index" do
        get admin_admin_users_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
