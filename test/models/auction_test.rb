require "test_helper"

class AuctionTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  setup do
    @live = auctions(:live)
    @seller, @admin, @buyer = users(:three), users(:one), users(:two)
  end

  test "phase follows status and time" do
    assert_equal :live, @live.phase
    assert_equal :upcoming, auctions(:upcoming).phase
    assert_equal :draft, auctions(:draft).phase
    assert_equal :closing, auctions(:expired).phase
  end

  test "ends_at must be after starts_at" do
    @live.ends_at = @live.starts_at
    assert_not @live.valid?
    assert @live.errors[:ends_at].any?
  end

  test "rejects non-image photos" do
    @live.photos.attach(io: file_fixture("evil.txt").open, filename: "evil.txt", content_type: "text/plain")
    assert_not @live.valid?
    assert @live.errors[:photos].any?
  end

  test "first bid must be at least the starting price, later bids add the increment" do
    assert_equal 10000, @live.minimum_bid
    assert_not @live.place_bid(user: @buyer, amount: 9999).persisted?

    assert @live.place_bid(user: @buyer, amount: 10000).persisted?
    assert_equal 10500, @live.reload.minimum_bid
    assert_not @live.place_bid(user: @admin, amount: 10499).persisted?
    assert @live.place_bid(user: @admin, amount: 10500).persisted?

    assert_equal 10500, @live.reload.current_price
    assert_equal 2, @live.bids_count
  end

  test "seller cannot bid on their own auction" do
    bid = @live.place_bid(user: @seller, amount: 20000)
    assert_not bid.persisted?
    assert_includes bid.errors[:base], "ไม่สามารถเสนอราคาสินค้าของตัวเองได้"
  end

  test "bids need place_bids permission" do
    @buyer.role.update!(permissions: [])
    assert_not @live.place_bid(user: @buyer, amount: 20000).persisted?
  end

  test "cannot bid before start or after end" do
    assert_not auctions(:upcoming).place_bid(user: @buyer, amount: 999_999).persisted?
    assert_not auctions(:expired).place_bid(user: @buyer, amount: 999_999).persisted?
    assert_not auctions(:draft).place_bid(user: @buyer, amount: 999_999).persisted?
  end

  test "outbid bidder is notified, not the one who raised their own bid" do
    @live.place_bid(user: @buyer, amount: 10000)
    assert_difference -> { @buyer.notifications.where(kind: "outbid").count }, 1 do
      @live.place_bid(user: @admin, amount: 11000)
    end
    assert_no_difference -> { Notification.count } do
      @live.place_bid(user: @admin, amount: 12000)
    end
  end

  test "close! picks the highest bidder and notifies winner and seller" do
    auction = auctions(:expired)
    assert auction.close!
    assert auction.ended?
    assert_equal users(:two), auction.winner
    assert_equal 5200, auction.current_price
    assert_equal %w[won], users(:two).notifications.pluck(:kind)
    assert_equal %w[sold], @seller.notifications.pluck(:kind)
  end

  test "close! is idempotent and does nothing before the end time" do
    auction = auctions(:expired)
    assert auction.close!
    assert_no_difference -> { Notification.count } do
      assert_not auction.close!
    end
    assert_not @live.close!
    assert @live.reload.published?
  end

  test "close! without bids notifies the seller as unsold" do
    @live.update_columns(ends_at: 1.second.ago)
    @live.close!
    assert_nil @live.winner
    assert_equal %w[unsold], @seller.notifications.pluck(:kind)
  end

  test "ending soon notifies each bidder once" do
    @live.place_bid(user: @buyer, amount: 10000)
    @live.place_bid(user: @admin, amount: 10500)
    @live.place_bid(user: @buyer, amount: 11000)
    assert_difference -> { Notification.where(kind: "ending_soon").count }, 2 do
      @live.notify_ending_soon!
      @live.notify_ending_soon!
    end
  end

  test "editable_by? rules" do
    assert auctions(:draft).editable_by?(@seller)
    assert auctions(:upcoming).editable_by?(@seller)
    assert_not @live.editable_by?(@seller), "live auctions are locked for the seller"
    assert @live.editable_by?(@admin), "manage_auctions can edit"
    assert_not auctions(:draft).editable_by?(@buyer)
    assert_not auctions(:draft).editable_by?(nil)
  end

  test "publishing schedules the close job" do
    assert_enqueued_with(job: CloseAuctionJob) do
      auctions(:draft).update!(status: "published")
    end
  end
end
