require "test_helper"

class Sms::MockTest < ActiveSupport::TestCase
  setup { Sms::Mock.clear }
  teardown { Sms::Mock.clear }

  test "deliver stores the message instead of sending it" do
    message = Sms::Mock.deliver(to: "0811111111", body: "hello")

    assert_equal "0811111111", message.to
    assert_equal [ message ], Sms::Mock.messages
    assert_equal message, Sms::Mock.last_message
  end

  test "keeps only the newest messages" do
    (Sms::Mock::MAX_MESSAGES + 5).times { |i| Sms::Mock.deliver(to: "0811111111", body: "m#{i}") }

    assert_equal Sms::Mock::MAX_MESSAGES, Sms::Mock.messages.size
    assert_equal "m#{Sms::Mock::MAX_MESSAGES + 4}", Sms::Mock.last_message.body
  end
end
