class ProductPhoto < ApplicationRecord
  CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_SIZE = 10.megabytes

  belongs_to :product, inverse_of: :photos

  # Variants are generated with libvips; strip: true removes EXIF/GPS metadata.
  has_one_attached :image do |image|
    image.variant :thumb, resize_to_fill: [ 400, 400 ], format: :webp, saver: { strip: true }
    image.variant :medium, resize_to_limit: [ 1200, nil ], format: :webp, saver: { strip: true }
    image.variant :large, resize_to_limit: [ 2000, nil ], format: :webp, saver: { strip: true }
  end

  validates :image, presence: { message: "ต้องเลือกรูป" }
  validate :image_type_and_size
  validate :product_photo_limit, on: :create

  before_validation :assign_next_position, on: :create

  # The cover is the photo with the lowest position (0 after a reorder).
  def cover?
    position == product.photos.first&.position
  end

  private
    # New photos go to the end. Siblings built in the same request are numbered in build order.
    def assign_next_position
      return if product.nil? || position.present?

      taken = product.photos.reject { it.equal?(self) }.filter_map(&:position)
      self.position = taken.empty? ? 0 : taken.max + 1
    end

    def image_type_and_size
      return unless image.attached?

      errors.add(:image, "ต้องเป็นไฟล์ JPG, PNG หรือ WEBP") unless image.content_type.in?(CONTENT_TYPES)
      errors.add(:image, "ต้องมีขนาดไม่เกิน 10MB") if image.byte_size > MAX_SIZE
    end

    def product_photo_limit
      return unless product&.persisted?

      errors.add(:base, "อัปโหลดได้สูงสุด #{Product::MAX_PHOTOS} รูป") if ProductPhoto.where(product: product).count >= Product::MAX_PHOTOS
    end
end
