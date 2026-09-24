# frozen_string_literal: true

class PaymentMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM", "noreply@example.com")

  def payment_success
    @user = params[:user]
    @plan = params[:plan]

    I18n.with_locale(@user.locale) do
      mail(
        to: @user.email,
        subject: t(".subject")
      )
    end
  end
end
