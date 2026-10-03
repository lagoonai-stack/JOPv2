class HomeController < ApplicationController
  def index
    @plans = Rails.application.config.stripe_plans.reject { |_key, cfg| cfg[:internal] }
  end
end
