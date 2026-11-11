require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "requires login" do
    get admin_products_path
    assert_redirected_to new_session_path
  end

  test "users without manage_products are turned away" do
    sign_in_as users(:two)
    get admin_products_path
    assert_redirected_to root_path
  end

  test "lists products as cards, hiding archived ones" do
    products(:pickup).archived!
    products(:transformer).photos.create!(image: { io: file_fixture("id_card.png").open, filename: "a.png", content_type: "image/png" })

    sign_in_as users(:one)
    get admin_products_path
    assert_response :success

    assert_select ".product-card", count: 1
    assert_select "#product_#{products(:transformer).id}" do
      assert_select ".product-card__name", text: "หม้อแปลงไฟฟ้า 50 kVA"
      assert_select ".sub", text: "หม้อแปลงไฟฟ้า"
      assert_select ".product-card__code", text: "PEA-TR-00123"
      assert_select ".status", text: "พร้อมประมูล"
      assert_select ".product-card__count", text: /1/
      assert_select "img[alt=?]", "หม้อแปลงไฟฟ้า 50 kVA รูปที่ 1"
    end
  end

  test "product without photos shows a placeholder" do
    sign_in_as users(:one)
    get admin_products_path
    assert_select "#product_#{products(:pickup).id} .product-card__placeholder"
    assert_select "#product_#{products(:pickup).id} .product-card__count", count: 0
  end

  test "empty state" do
    Product.delete_all
    sign_in_as users(:one)
    get admin_products_path
    assert_select ".empty-state h2", text: "ยังไม่มีสินค้า"
    assert_select ".product-card", count: 0
  end
end
