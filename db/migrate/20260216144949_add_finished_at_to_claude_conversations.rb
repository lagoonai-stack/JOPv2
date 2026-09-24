# frozen_string_literal: true

class AddFinishedAtToClaudeConversations < ActiveRecord::Migration[8.1]
  def change
    add_column :claude_conversations, :finished_at, :datetime

    remove_index :claude_conversations, name: "index_claude_conv_on_user_and_agent"
    add_index :claude_conversations, %i[user_id agent_name],
              unique: true,
              where: "finished_at IS NULL",
              name: "index_claude_conv_active_user_agent"
    add_index :claude_conversations, %i[user_id agent_name finished_at],
              name: "index_claude_conv_on_user_agent_finished"
  end
end
