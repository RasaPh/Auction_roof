class CreateAuctions < ActiveRecord::Migration[8.1]
  def change
    create_table :auctions do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.decimal :starting_price, precision: 14, scale: 2, null: false
      t.decimal :min_increment, precision: 14, scale: 2, null: false
      t.decimal :current_price, precision: 14, scale: 2
      t.integer :bids_count, null: false, default: 0
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :status, null: false, default: "draft"
      t.references :winner, foreign_key: { to_table: :users }
      t.datetime :closed_at
      t.datetime :ending_soon_notified_at
      t.timestamps
    end
    add_index :auctions, [ :status, :ends_at ]
    add_index :auctions, :starts_at

    create_table :bids do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 14, scale: 2, null: false
      t.timestamps
    end
    add_index :bids, [ :auction_id, :amount ]
  end
end
