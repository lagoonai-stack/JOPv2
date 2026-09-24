class AddComponentCodeToClaudeConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :claude_conversations, :component_code, :text
  end
end