class CreateReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :referrals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :referrer, null: false, foreign_key: { to_table: :users }
      t.references :referral_code, null: false, foreign_key: true
      t.integer :level, null: false, default: 1
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :referrals, [:user_id, :referrer_id], unique: true
    add_index :referrals, :level
    add_index :referrals, :status
  end
end
