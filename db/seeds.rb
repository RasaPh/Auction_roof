# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin = Role.find_or_create_by!(name: "ผู้ดูแลระบบ") { it.permissions = Role::PERMISSIONS.keys }
admin.update!(permissions: admin.permissions | %w[ manage_products ])
Role.find_or_create_by!(name: "ผู้ขาย") { it.permissions = %w[ create_auctions place_bids ] }
Role.find_or_create_by!(name: "ผู้ซื้อ") { it.permissions = %w[ place_bids ] }

[ "หม้อแปลงไฟฟ้า", "ยานพาหนะ", "สายไฟ/เศษโลหะ", "อุปกรณ์ไฟฟ้า", "เครื่องจักร", "ครุภัณฑ์สำนักงาน" ].each_with_index do |name, i|
  ProductCategory.find_or_create_by!(name: name) { it.position = i }
end
