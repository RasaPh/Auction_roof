require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "requires view_reports" do
    sign_in_as users(:two)
    get admin_reports_path
    assert_redirected_to root_path
  end

  test "shows totals" do
    auctions(:expired).close!
    sign_in_as users(:one)
    get admin_reports_path
    assert_response :success
    assert_select ".stat strong", text: "฿5,200"
    assert_select "td a", text: auctions(:expired).title
  end
end
