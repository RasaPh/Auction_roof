class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone, null: false
      t.string :email_address
      t.string :password_digest, null: false

      # Forgot-password OTP (stored hashed, never in plain text)
      t.string :otp_digest
      t.datetime :otp_expires_at
      t.integer :otp_attempts, null: false, default: 0

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :phone, unique: true
  end
end
