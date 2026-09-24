# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Theme (light/dark mode)", type: :request do
  describe "layout" do
    it "includes theme controller and toggle on every page" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-controller="theme"')
      expect(response.body).to include("theme#toggle")
      expect(response.body).to include("theme-toggle")
    end

    it "includes theme script in head for no flash" do
      get root_path

      expect(response.body).to include("data-theme")
      expect(response.body).to include("localStorage.getItem('theme')")
    end
  end
end
