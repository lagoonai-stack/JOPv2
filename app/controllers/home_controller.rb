class HomeController < ApplicationController
  def index
    @plans = Rails.application.config.stripe_plans
  end
end
