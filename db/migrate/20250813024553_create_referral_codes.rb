class CreateReferralCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :referral_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :referral_codes, :code, unique: true
  end
end
