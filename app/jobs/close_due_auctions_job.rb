# Safety net, run every minute: closes any auction whose scheduled CloseAuctionJob was missed.
class CloseDueAuctionsJob < ApplicationJob
  queue_as :default

  def perform
    Auction.due_to_close.find_each(&:close!)
  end
end
