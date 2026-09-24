# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_18_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "claude_conversations", force: :cascade do |t|
    t.string "agent_name", default: "movie-maker", null: false
    t.integer "ai_attempts"
    t.string "ai_model"
    t.text "component_code"
    t.string "component_id"
    t.datetime "created_at", null: false
    t.json "detected_skills"
    t.datetime "finished_at"
    t.text "generation_prompt"
    t.string "preview_token"
    t.datetime "preview_token_expires_at"
    t.string "render_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "video_file_path"
    t.jsonb "video_spec"
    t.string "video_status", default: "idle"
    t.index ["ai_model"], name: "index_claude_conversations_on_ai_model"
    t.index ["component_id"], name: "index_claude_conversations_on_component_id"
    t.index ["preview_token"], name: "index_claude_conversations_on_preview_token", unique: true, where: "(preview_token IS NOT NULL)"
    t.index ["render_id"], name: "index_claude_conversations_on_render_id", unique: true, where: "(render_id IS NOT NULL)"
    t.index ["user_id", "agent_name", "finished_at"], name: "index_claude_conv_on_user_agent_finished"
    t.index ["user_id", "agent_name"], name: "index_claude_conv_active_user_agent", unique: true, where: "(finished_at IS NULL)"
    t.index ["user_id"], name: "index_claude_conversations_on_user_id"
  end

  create_table "claude_messages", force: :cascade do |t|
    t.integer "cache_creation_input_tokens", default: 0, null: false
    t.integer "cache_read_input_tokens", default: 0, null: false
    t.bigint "claude_conversation_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "input_tokens", default: 0
    t.integer "output_tokens", default: 0
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["claude_conversation_id"], name: "index_claude_messages_on_claude_conversation_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "brl", null: false
    t.string "plan", null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_session_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_payments_on_created_at"
    t.index ["stripe_session_id"], name: "index_payments_on_stripe_session_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "locale", default: "en", null: false
    t.datetime "remember_created_at"
    t.datetime "subscription_period_ends_at"
    t.datetime "subscription_period_started_at"
    t.string "subscription_plan"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index "lower((username)::text)", name: "index_users_on_lower_username", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "claude_conversations", "users"
  add_foreign_key "claude_messages", "claude_conversations"
  add_foreign_key "payments", "users"
end
