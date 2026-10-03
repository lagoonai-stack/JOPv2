# frozen_string_literal: true

# History of conversational adjustments applied to a conversation's preview
# (VideoController#request_edit), oldest first. Each entry records the
# instruction, when it was applied, and the generator's attempts/problems —
# it is both the context sent back to the generator and edit telemetry.
class AddVideoEditsToClaudeConversations < ActiveRecord::Migration[8.1]
  def change
    add_column :claude_conversations, :video_edits, :jsonb, default: [], null: false
  end
end
