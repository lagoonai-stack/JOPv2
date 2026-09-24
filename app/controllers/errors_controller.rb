# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout "application"

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.any { head :not_found }
    end
  end
end
