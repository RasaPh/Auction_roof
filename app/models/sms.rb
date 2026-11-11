# SMS gateway. Picks a provider from SMS_PROVIDER (default "mock") and delegates to it.
#
# A provider is any class under Sms:: that responds to `deliver(to:, body:)`.
# To add a real one (Twilio, ThaiBulkSMS, ...), create Sms::Twilio, register it in
# PROVIDERS and set SMS_PROVIDER=twilio.
module Sms
  PROVIDERS = {
    "mock" => "Sms::Mock"
  }.freeze

  class UnknownProvider < StandardError; end

  class << self
    def deliver(to:, body:)
      provider.deliver(to: to, body: body)
    end

    def provider
      name = ENV.fetch("SMS_PROVIDER", "mock")
      PROVIDERS.fetch(name) { raise UnknownProvider, "Unknown SMS_PROVIDER #{name.inspect} (available: #{PROVIDERS.keys.join(', ')})" }.constantize
    end
  end
end
