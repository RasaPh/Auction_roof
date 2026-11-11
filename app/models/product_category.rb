class ProductCategory < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  normalizes :name, with: ->(n) { n.strip }

  validates :name, presence: { message: "ต้องกรอก" }, uniqueness: { case_sensitive: false, message: "มีอยู่แล้ว" },
    length: { maximum: 100 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }
end
