class Product < ApplicationRecord
  MAX_PHOTOS = 10

  CONDITIONS = { "usable" => "ใช้งานได้", "damaged" => "ชำรุด", "scrap" => "ซาก" }.freeze
  STATUSES = { "draft" => "ร่าง", "ready" => "พร้อมประมูล", "archived" => "เก็บถาวร" }.freeze

  belongs_to :product_category
  belongs_to :owner_user, class_name: "User", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true

  has_many :photos, -> { order(:position, :id) }, class_name: "ProductPhoto", inverse_of: :product, dependent: :destroy
  has_one :cover_photo, -> { order(:position, :id) }, class_name: "ProductPhoto"

  enum :condition, CONDITIONS.keys.index_by(&:itself), validate: { message: "ไม่ถูกต้อง" }
  enum :status, STATUSES.keys.index_by(&:itself), validate: { message: "ไม่ถูกต้อง" }

  normalizes :name, :owner_name, :unit, :location_province, with: ->(v) { v.strip }
  normalizes :asset_code, with: ->(c) { c.strip.upcase.presence }
  normalizes :owner_phone, with: ->(p) { p.gsub(/\D/, "") }

  validates :name, presence: { message: "ต้องกรอก" }, length: { maximum: 200 }
  validates :asset_code, uniqueness: { case_sensitive: false, message: "ถูกใช้แล้ว" }, length: { maximum: 50 }, allow_nil: true
  validates :owner_name, presence: { message: "ต้องกรอก" }, length: { maximum: 200 }
  validates :owner_phone, presence: { message: "ต้องกรอก" },
    format: { with: /\A0\d{9}\z/, message: "ต้องเป็นเบอร์ 10 หลัก ขึ้นต้นด้วย 0", allow_blank: true }
  validates :quantity, numericality: { only_integer: true, greater_than: 0, message: "ต้องเป็นจำนวนเต็มมากกว่า 0" }
  validates :unit, presence: { message: "ต้องกรอก" }, length: { maximum: 30 }
  validates :appraised_price, numericality: { greater_than_or_equal_to: 0, message: "ต้องไม่ติดลบ" }, allow_nil: true
  validate :photo_limit

  scope :not_archived, -> { where.not(status: "archived") }

  def condition_label = CONDITIONS[condition]
  def status_label = STATUSES[status]

  private
    def photo_limit
      errors.add(:photos, "อัปโหลดได้สูงสุด #{MAX_PHOTOS} รูป") if photos.reject(&:marked_for_destruction?).size > MAX_PHOTOS
    end
end
