module SessionTestHelper
  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end

module OtpTestHelper
  # Runs the block and returns the OTP code that would have been sent.
  def capture_otp
    sent = nil
    original = OtpSender.method(:deliver)
    OtpSender.define_singleton_method(:deliver) { |phone:, code:| sent = code }
    yield
    sent
  ensure
    OtpSender.define_singleton_method(:deliver, original)
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include OtpTestHelper
end
