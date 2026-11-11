class EndingSoonJob < ApplicationJob
  queue_as :default

  def perform(auction)
    # The end time may have changed since this job was scheduled.
    return unless auction.biddable? && auction.ends_at - Auction::ENDING_SOON <= 1.minute.from_now
    auction.notify_ending_soon!
  end
end
