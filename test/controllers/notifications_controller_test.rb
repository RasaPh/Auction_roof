require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @notification = @user.notifications.create!(kind: "outbid", auction: auctions(:live), message: "มีผู้เสนอราคาสูงกว่าคุณ")
  end

  test "lists my notifications and shows the unread badge" do
    sign_in_as @user
    get notifications_path
    assert_response :success
    assert_select ".notif.is-unread", 1
    assert_select "#notification_badge", text: "1"
  end

  test "reading a notification opens its auction" do
    sign_in_as @user
    patch read_notification_path(@notification)
    assert_redirected_to auction_path(auctions(:live))
    assert @notification.reload.read?
  end

  test "cannot read someone else's notification" do
    sign_in_as users(:one)
    patch read_notification_path(@notification)
    assert_response :not_found
  end

  test "read all" do
    sign_in_as @user
    post read_all_notifications_path
    assert_equal 0, @user.notifications.unread.count
  end
end
