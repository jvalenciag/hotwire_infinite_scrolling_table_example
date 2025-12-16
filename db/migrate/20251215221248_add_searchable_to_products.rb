class AddSearchableToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :searchable, :virtual, type: :tsvector,
      as: "setweight(to_tsvector('simple', name), 'A') || setweight(to_tsvector('simple', description), 'B')",
      stored: true

    add_index :products, :searchable, using: :gin
  end
end
