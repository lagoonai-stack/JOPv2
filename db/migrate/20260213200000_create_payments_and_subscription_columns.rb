# frozen_string_literal: true

class CreatePaymentsAndSubscriptionColumns < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plan, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "brl"
      t.string :stripe_session_id
      t.string :stripe_payment_intent_id
      t.string :status, null: false, default: "pending"
      t.timestamps
    end

    add_index :payments, :stripe_session_id, unique: true
    add_index :payments, :created_at

    add_column :users, :subscription_plan, :string
    add_column :users, :subscription_period_started_at, :datetime
    add_column :users, :subscription_period_ends_at, :datetime
  end
end
