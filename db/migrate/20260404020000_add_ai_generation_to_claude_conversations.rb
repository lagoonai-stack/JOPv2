# frozen_string_literal: true

class AddAiGenerationToClaudeConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :claude_conversations, :generation_prompt, :text
    add_column :claude_conversations, :ai_model, :string
    add_column :claude_conversations, :ai_attempts, :integer
    add_column :claude_conversations, :detected_skills, :json

    add_index :claude_conversations, :ai_model
  end
end
