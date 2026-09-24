# frozen_string_literal: true

class AddVideoFieldsToClaudeConversations < ActiveRecord::Migration[8.1]
  def change
    add_column :claude_conversations, :video_spec, :jsonb
    add_column :claude_conversations, :video_status, :string, default: "idle"
    add_column :claude_conversations, :render_id, :string
    add_column :claude_conversations, :preview_token, :string
    add_column :claude_conversations, :preview_token_expires_at, :datetime
    add_column :claude_conversations, :video_file_path, :string

    add_index :claude_conversations, :preview_token, unique: true, where: "preview_token IS NOT NULL"
    add_index :claude_conversations, :render_id, unique: true, where: "render_id IS NOT NULL"
  end
end
