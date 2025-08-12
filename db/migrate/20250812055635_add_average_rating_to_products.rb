class AddAverageRatingToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :average_rating, :decimal
  end
end
