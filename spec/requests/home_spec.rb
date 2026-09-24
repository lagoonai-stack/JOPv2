# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "when not signed in" do
      it "shows pricing page to guests" do
        get root_url

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t("home.hero_title"))
        expect(response.body).to include(I18n.t("home.register"))
        expect(response.body).not_to include("Signed in as")
      end
    end

    context "when signed in" do
      let(:user) { create(:user) }

      it "shows personalized nav" do
        sign_in user, scope: :user
        get root_url

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Signed in as")
        expect(response.body).to include(user.username)
      end
    end
  end
end
