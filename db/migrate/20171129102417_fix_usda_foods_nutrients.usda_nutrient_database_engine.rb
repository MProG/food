# This migration comes from usda_nutrient_database_engine (originally 12)
class FixUsdaFoodsNutrients < ActiveRecord::Migration[4.2]
  def change
    remove_column :usda_foods_nutrients, :id
  end
end
