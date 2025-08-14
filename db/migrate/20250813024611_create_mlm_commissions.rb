class CreateMlmCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :mlm_commissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :referrer, null: false, foreign_key: { to_table: :users }
      t.references :order, null: false, foreign_key: true
      t.integer :level, null: false
      t.decimal :commission_amount, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'pending'
      t.text :description

      t.timestamps
    end

    add_index :mlm_commissions, :level
    add_index :mlm_commissions, :status
    add_index :mlm_commissions, :created_at
  end
end
