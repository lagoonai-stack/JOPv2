# frozen_string_literal: true

class CreateClaudeConversationsAndMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :claude_conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :agent_name, null: false, default: "movie-maker"
      t.timestamps
    end

    add_index :claude_conversations, [:user_id, :agent_name], unique: true, name: "index_claude_conv_on_user_and_agent"

    create_table :claude_messages do |t|
      t.references :claude_conversation, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: false
      t.integer :input_tokens, default: 0
      t.integer :output_tokens, default: 0
      t.timestamps
    end
  end
end
