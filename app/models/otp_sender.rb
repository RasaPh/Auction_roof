# Delivers password-reset OTP codes.
#
# There is no SMS provider connected yet, so the code is only written to the log.
# To send real SMS, call your provider (e.g. Twilio, ThaiBulkSMS) inside `deliver`.
class OtpSender
  def self.deliver(phone:, code:)
    Rails.logger.info("[OTP] phone=#{phone} code=#{code}")
  end
end
