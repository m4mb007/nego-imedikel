class CreateProductVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name
      t.string :sku
      t.decimal :price
      t.integer :stock_quantity
      t.jsonb :variant_attributes

      t.timestamps
    end
  end
end
