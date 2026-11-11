require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def build_product(**attrs)
    Product.new(product_category: product_categories(:transformer), name: "สายไฟ", owner_name: "ก ข",
      owner_phone: "0811112222", **attrs)
  end

  def image(name = "id_card.png", content_type = "image/png")
    { io: file_fixture(name).open, filename: name, content_type: content_type }
  end

  test "defaults" do
    product = build_product
    assert product.valid?
    assert_equal 1, product.quantity
    assert_equal "ชิ้น", product.unit
    assert product.usable?
    assert product.draft?
  end

  test "required fields have Thai messages" do
    product = Product.new
    assert_not product.valid?
    assert_includes product.errors[:name], "ต้องกรอก"
    assert_includes product.errors[:owner_name], "ต้องกรอก"
    assert_includes product.errors[:owner_phone], "ต้องกรอก"
    assert product.errors[:product_category].any?
  end

  test "owner phone is normalized and must be 10 digits starting with 0" do
    assert_equal "0811112222", build_product(owner_phone: "081-111-2222").owner_phone
    assert_not build_product(owner_phone: "1234567890").valid?
    assert_not build_product(owner_phone: "081111222").valid?
  end

  test "asset code is optional, upcased and unique" do
    assert_nil build_product(asset_code: "  ").asset_code
    assert build_product(asset_code: nil).valid?
    assert_not build_product(asset_code: " pea-tr-00123 ").valid?

    build_product(asset_code: nil).save!
    assert build_product(asset_code: nil).save, "several products may have no asset code"
  end

  test "quantity must be a positive integer and price not negative" do
    assert_not build_product(quantity: 0).valid?
    assert_not build_product(quantity: 1.5).valid?
    assert_not build_product(appraised_price: -1).valid?
    assert build_product(appraised_price: nil).valid?
  end

  test "rejects unknown condition and status" do
    assert_not build_product(condition: "new").valid?
    assert_not build_product(status: "sold").valid?
  end

  test "labels and not_archived scope" do
    product = products(:transformer)
    assert_equal "ชำรุด", product.condition_label
    assert_equal "พร้อมประมูล", product.status_label

    product.archived!
    assert_not_includes Product.not_archived, product
    assert_includes Product.not_archived, products(:pickup)
  end

  test "photos built together are numbered in order and the first is the cover" do
    product = build_product
    3.times { product.photos.build(image: image) }
    product.save!

    assert_equal [ 0, 1, 2 ], product.photos.reload.map(&:position)
    assert_equal product.photos.first, product.cover_photo
    assert product.cover_photo.cover?
    assert_not product.photos.last.cover?
  end

  test "a photo added later goes to the end" do
    product = products(:pickup)
    first = product.photos.create!(image: image)
    second = ProductPhoto.create!(product: product, image: image)

    assert_equal [ 0, 1 ], [ first.position, second.position ]
  end

  test "at most 10 photos" do
    product = build_product
    11.times { product.photos.build(image: image) }
    assert_not product.valid?
    assert_includes product.errors[:photos], "อัปโหลดได้สูงสุด 10 รูป"

    product = build_product
    10.times { product.photos.build(image: image) }
    product.save!

    extra = ProductPhoto.new(product: product, image: image)
    assert_not extra.valid?
    assert_includes extra.errors[:base], "อัปโหลดได้สูงสุด 10 รูป"
  end

  test "photo must be an image of allowed type" do
    photo = ProductPhoto.new(product: products(:pickup), image: image("evil.txt", "text/plain"))
    assert_not photo.valid?
    assert_includes photo.errors[:image], "ต้องเป็นไฟล์ JPG, PNG หรือ WEBP"
    assert_not ProductPhoto.new(product: products(:pickup)).valid?
  end

  test "destroying a product removes its photos" do
    product = products(:pickup)
    product.photos.create!(image: image)
    assert_difference -> { ProductPhoto.count }, -1 do
      product.destroy!
    end
  end
end
