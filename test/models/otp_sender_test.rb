require "test_helper"

class OtpSenderTest < ActiveSupport::TestCase
  setup { Sms::Mock.clear }
  teardown { Sms::Mock.clear }

  test "sends the code to the phone through the SMS provider" do
    OtpSender.deliver(phone: "0811111111", code: "4821")

    message = Sms::Mock.last_message
    assert_equal "0811111111", message.to
    assert_includes message.body, "4821"
  end
end
