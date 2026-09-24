# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "GET unknown path" do
    it "returns 404 and renders not_found page" do
      get "/nonexistent-page"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include(I18n.t("errors.not_found.title"))
      expect(response.body).to include(I18n.t("errors.not_found.back_home"))
    end
  end
end
