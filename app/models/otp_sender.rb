# Delivers password-reset OTP codes by SMS through the configured provider (see Sms).
class OtpSender
  def self.deliver(phone:, code:)
    Sms.deliver(to: phone, body: "รหัส OTP ของคุณคือ #{code} (หมดอายุใน #{User::OTP_TTL.in_minutes.to_i} นาที) ห้ามบอกรหัสนี้กับผู้อื่น")
  end
end
