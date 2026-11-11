require "test_helper"

class SmsTest < ActiveSupport::TestCase
  setup { Sms::Mock.clear }
  teardown { Sms::Mock.clear }

  test "defaults to the mock provider" do
    assert_equal Sms::Mock, Sms.provider
    Sms.deliver(to: "0811111111", body: "hi")
    assert_equal "hi", Sms::Mock.last_message.body
  end

  test "unknown provider raises a helpful error" do
    original = ENV["SMS_PROVIDER"]
    ENV["SMS_PROVIDER"] = "nope"
    error = assert_raises(Sms::UnknownProvider) { Sms.provider }
    assert_match(/nope.*mock/, error.message)
  ensure
    original ? ENV["SMS_PROVIDER"] = original : ENV.delete("SMS_PROVIDER")
  end
end
