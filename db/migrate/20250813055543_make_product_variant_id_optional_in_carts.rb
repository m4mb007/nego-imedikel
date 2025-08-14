class MakeProductVariantIdOptionalInCarts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :carts, :product_variant_id, true
  end
end
