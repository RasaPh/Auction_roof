class CloseAuctionJob < ApplicationJob
  queue_as :default

  # Runs at ends_at. If the end time was moved later, close! does nothing and the newer job handles it.
  def perform(auction)
    auction.close!
  end
end
