require "test_helper"

class AuctionJobsTest < ActiveJob::TestCase
  test "CloseDueAuctionsJob closes only auctions whose time is up" do
    CloseDueAuctionsJob.perform_now
    assert auctions(:expired).reload.ended?
    assert auctions(:live).reload.published?
  end

  test "CloseAuctionJob does nothing if the end time moved later" do
    auction = auctions(:live)
    CloseAuctionJob.perform_now(auction)
    assert auction.reload.published?
  end

  test "EndingSoonJob only fires inside the warning window" do
    auction = auctions(:live)
    auction.place_bid(user: users(:two), amount: 10000)
    assert_no_difference -> { Notification.count } do
      EndingSoonJob.perform_now(auction)
    end
    auction.update_columns(ends_at: 5.minutes.from_now)
    assert_difference -> { Notification.count }, 1 do
      EndingSoonJob.perform_now(auction.reload)
    end
  end
end
