class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :sku
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.boolean :featured
      t.integer :stock_quantity
      t.decimal :weight
      t.string :dimensions
      t.string :brand

      t.timestamps
    end
  end
end
