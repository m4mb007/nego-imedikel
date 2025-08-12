class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :message
      t.integer :notification_type
      t.datetime :read_at
      t.jsonb :data

      t.timestamps
    end
  end
end
