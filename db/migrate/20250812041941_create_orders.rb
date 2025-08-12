class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.decimal :total_amount
      t.integer :status
      t.integer :payment_status
      t.text :shipping_address
      t.text :billing_address
      t.string :tracking_number

      t.timestamps
    end
  end
end
