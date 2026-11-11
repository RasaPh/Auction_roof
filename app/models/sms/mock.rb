# Fake SMS provider: nothing is sent. Messages are kept in memory (per process, newest last,
# capped) so they can be inspected in dev and asserted on in tests.
#
# The message body is written to the log everywhere except production, because it contains OTP codes.
module Sms
  class Mock
    MAX_MESSAGES = 100
    Message = Data.define(:to, :body, :sent_at)

    @messages = []
    @lock = Mutex.new

    class << self
      def deliver(to:, body:)
        message = Message.new(to: to, body: body, sent_at: Time.current)
        @lock.synchronize do
          @messages << message
          @messages.shift while @messages.size > MAX_MESSAGES
        end
        log(message)
        message
      end

      def messages
        @lock.synchronize { @messages.dup }
      end

      def last_message
        messages.last
      end

      def clear
        @lock.synchronize { @messages.clear }
      end

      private
        def log(message)
          text = Rails.env.production? ? "#{message.body.length} chars" : message.body
          Rails.logger.info("[SMS:mock] to=#{message.to} #{text}")
        end
    end
  end
end
