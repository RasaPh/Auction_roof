class CreateProductCatalog < ActiveRecord::Migration[8.1]
  def change
    create_table :product_categories do |t|
      t.string :name, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :product_categories, :name, unique: true

    create_table :products do |t|
      t.references :product_category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :asset_code
      t.text :description
      t.string :owner_name, null: false
      t.string :owner_phone, null: false
      t.references :owner_user, foreign_key: { to_table: :users }
      t.text :owner_note
      t.integer :quantity, null: false, default: 1
      t.string :unit, null: false, default: "ชิ้น"
      t.string :condition, null: false, default: "usable"
      t.string :location_province
      t.decimal :appraised_price, precision: 14, scale: 2
      t.string :status, null: false, default: "draft"
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :products, :status
    add_index :products, :asset_code, unique: true, where: "asset_code IS NOT NULL"

    create_table :product_photos do |t|
      t.references :product, null: false, foreign_key: true, index: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :product_photos, [ :product_id, :position ]
  end
end
