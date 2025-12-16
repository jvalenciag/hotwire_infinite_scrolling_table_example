# rubocop:disable Rails/SkipsModelValidations
require "csv"

DATA_PATH = "db/data"
def get_file_path(filename)
  File.join(DATA_PATH, filename)
end
CSV.foreach(get_file_path("Marcas.csv"), headers: true).each_slice(200) do |batch|
  brands_to_insert = batch.map do |line|
    { id: line["idMarca"], name: line["Marca"], short_name: line["Abrev"] }
  end
  Brand.insert_all(brands_to_insert)
end

CSV.foreach(get_file_path("Items.csv"), headers: true).each_slice(200) do |batch|
  products_to_insert = batch.map do |line|
    { id: line["idItem"].to_i, name: line["NombreItm"], brand_id: line["idMarca"].to_i, description: line["Otros"] }
  end
  Product.insert_all(products_to_insert)
end

puts "Seeded #{Brand.count} brands"
puts "Seeded #{Product.count} products"
# rubocop:enable Rails/SkipsModelValidations
