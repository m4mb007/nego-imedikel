class CreateRewardWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :reward_wallets do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :points, default: 0, null: false

      t.timestamps
    end
  end
end
