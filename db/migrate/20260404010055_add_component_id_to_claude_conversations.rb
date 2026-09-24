# frozen_string_literal: true

class AddComponentIdToClaudeConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :claude_conversations, :component_id, :string
    add_index :claude_conversations, :component_id
  end
end
