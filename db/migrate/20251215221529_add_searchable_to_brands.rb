class AddSearchableToBrands < ActiveRecord::Migration[8.1]
  def change
    add_column :brands, :searchable, :virtual, type: :tsvector,
      as: "setweight(to_tsvector('simple', name), 'A') || setweight(to_tsvector('simple', short_name), 'B')",
      stored: true

    add_index :brands, :searchable, using: :gin
  end
end
