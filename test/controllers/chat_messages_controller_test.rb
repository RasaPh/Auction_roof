require "test_helper"

class ChatMessagesControllerTest < ActionDispatch::IntegrationTest
  setup { @auction = auctions(:live) }

  test "signed-in users post messages that are broadcast" do
    sign_in_as users(:two)
    assert_turbo_stream_broadcasts [ @auction, :chat ], count: 1 do
      post auction_chat_messages_path(@auction), params: { chat_message: { body: "  สนใจครับ  " } }, as: :turbo_stream
    end
    assert_response :success
    assert_equal "สนใจครับ", @auction.chat_messages.last.body
  end

  test "guests cannot chat" do
    post auction_chat_messages_path(@auction), params: { chat_message: { body: "hi" } }
    assert_redirected_to new_session_path
  end

  test "no chat on drafts" do
    sign_in_as users(:three)
    post auction_chat_messages_path(auctions(:draft)), params: { chat_message: { body: "hi" } }
    assert_response :not_found
  end

  test "only manage_auctions can delete messages" do
    message = @auction.chat_messages.create!(user: users(:two), body: "spam")
    sign_in_as users(:two)
    delete auction_chat_message_path(@auction, message)
    assert ChatMessage.exists?(message.id)

    sign_in_as users(:one)
    delete auction_chat_message_path(@auction, message)
    assert_not ChatMessage.exists?(message.id)
  end
end
