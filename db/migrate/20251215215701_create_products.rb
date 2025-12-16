class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
      t.string :model
      t.string :sku
      t.boolean :enabled, null: false, default: true
      t.timestamp :deleted_at
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
  end
end
