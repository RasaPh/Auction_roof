require "test_helper"

class ProductCategoryTest < ActiveSupport::TestCase
  test "name is required and unique, ignoring case and spaces" do
    assert_not ProductCategory.new(name: " ").valid?
    assert_not ProductCategory.new(name: "  หม้อแปลงไฟฟ้า ").valid?
    assert ProductCategory.new(name: "เครื่องจักร").valid?
  end

  test "active and ordered scopes" do
    assert_not_includes ProductCategory.active, product_categories(:inactive)
    assert_equal product_categories(:transformer), ProductCategory.ordered.first
  end

  test "cannot destroy a category that still has products" do
    assert_not product_categories(:transformer).destroy
    assert ProductCategory.exists?(product_categories(:transformer).id)
  end
end
