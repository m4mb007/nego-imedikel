class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.text :address
      t.string :phone
      t.string :email
      t.string :website
      t.integer :status
      t.datetime :verified_at

      t.timestamps
    end
  end
end
