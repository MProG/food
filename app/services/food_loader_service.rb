class FoodLoaderService
  FOOD_SPREADSHEET = './foods.csv'
  NUTRIENT_SPREADSHEET = './nutrients.csv'

  def self.read_food_csv
    rows = Roo::Spreadsheet.open(FOOD_SPREADSHEET).sheet(0).parse
    rows.each do |row|
      Product.create(name: row[1], upc: row[2], dnbo: row[0])
    end
  end

  def self.import_full_food
    loop do
      food = Product.where(imported: false).sample
      res = UploadService.new.get_food_data(food) if food
      break if food.nil? || res.class != CSV
      food.update(imported: true)
    end
  end

  def self.read_nutrient_csv
    rows = Roo::Spreadsheet.open(NUTRIENT_SPREADSHEET).sheet(0).parse
    rows.each do |row|
      Nutrient.create(name: row[1], dnbo: row[0])
    end
  end
end
