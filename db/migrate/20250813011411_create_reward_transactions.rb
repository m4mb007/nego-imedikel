class CreateRewardTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :reward_transactions do |t|
      t.references :reward_wallet, null: false, foreign_key: true
      t.string :transaction_type, null: false
      t.integer :amount, null: false
      t.text :description
      t.references :order, null: true, foreign_key: true

      t.timestamps
    end
    
    add_index :reward_transactions, :transaction_type
    add_index :reward_transactions, :created_at
  end
end
