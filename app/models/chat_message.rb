class ChatMessage < ApplicationRecord
  belongs_to :auction
  belongs_to :user

  normalizes :body, with: ->(b) { b.strip }
  validates :body, presence: true, length: { maximum: 500 }

  after_create_commit -> { broadcast_append_to auction, :chat, target: ActionView::RecordIdentifier.dom_id(auction, :chat_messages), partial: "chat_messages/chat_message", locals: { chat_message: self } }
  after_destroy_commit -> { broadcast_remove_to auction, :chat }
end
