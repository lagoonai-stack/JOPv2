ActiveAdmin.register User do
  permit_params :email, :username, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :created_at
    column :total_claude_tokens, sortable: false do |user|
      span user.total_claude_tokens, class: "badge badge--tokens"
    end
    actions
  end

  filter :email
  filter :username
  filter :created_at

  show do
    div class: "show-page-layout" do
      panel "Account", class: "panel--main" do
        attributes_table_for resource do
          row :id
          row :username
          row :email
          row :created_at
          row :updated_at
        end
      end

      panel "Claude (Just One Prompt) token usage", class: "panel--tokens" do
        attributes_table_for resource do
          row "Total tokens" do
            strong resource.total_claude_tokens
          end
          row "Input tokens" do
            resource.total_claude_input_tokens
          end
          row "Output tokens" do
            resource.total_claude_output_tokens
          end
        end
        if resource.claude_conversations.any?
          div class: "token-conversations" do
            span "Conversations: ", class: "token-conversations__label"
            span resource.claude_conversations.count, class: "token-conversations__count"
          end
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :username
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
