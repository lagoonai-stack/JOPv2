# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "dashboard-columns" do
      columns style: "display: flex;" do
        column span: 2 do
          panel "New users (past 30 days)" do
            div class: "dashboard-stat" do
              span User.created_in_last(days: 30).count.to_s
              span " users", class: "dashboard-stat__unit"
            end
          end
        end

        column span: 2 do
          panel "Payments (past 30 days)" do
            last_payments = Payment.completed.in_last_days(days: 30)
            total_amount = last_payments.sum(:amount_cents)

            div class: "dashboard-stat" do
              span last_payments.count.to_s
              span " payments", class: "dashboard-stat__unit", style: "margin-right: 10px;"

              span number_to_currency(total_amount / 100.0, unit: "R$ ", separator: ",",
                                                            delimiter: ".", format: "%u %n")
              span " total", class: "dashboard-stat__unit"
            end
          end
        end
      end

      columns style: "display: flex;" do
        column span: 2 do
          panel "Average tokens used per day (last 30 days)" do
            div class: "dashboard-stat" do
              span ClaudeMessage.average_tokens_per_day(days: 30).to_s
              span " tokens/day", class: "dashboard-stat__unit"
            end
          end
        end

        column span: 2 do
          panel "Average payments per day (last 30 days)" do
            div class: "dashboard-stat" do
              span number_to_currency(Payment.average_amount_per_day(days: 30) / 100.0, unit: "R$ ", separator: ",",
                                                                                        delimiter: ".", format: "%u %n")
              span " revenue/day", class: "dashboard-stat__unit"
            end
          end
        end
      end

      columns do
        column span: 2 do
          panel "Payments per day (last 30 days)" do
            payments_by_day = Payment.completed.where(created_at: 30.days.ago..)
                                     .group_by_day(:created_at)
                                     .sum(:amount_cents)
                                     .transform_values! { |cents| (cents / 100.0).round(2) }

            line_chart payments_by_day,
                       height: "300px",
                       prefix: "R$ ",
                       thousands: ".",
                       decimal: ",",
                       precision: 4
          end
        end
      end
    end
  end
end
