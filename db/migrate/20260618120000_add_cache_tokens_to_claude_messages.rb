# frozen_string_literal: true

class AddCacheTokensToClaudeMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :claude_messages, :cache_creation_input_tokens, :integer, default: 0, null: false
    add_column :claude_messages, :cache_read_input_tokens, :integer, default: 0, null: false
  end
end
