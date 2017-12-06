# This migration comes from usda_nutrient_database_engine (originally 11)
class FixUsdaWeights < ActiveRecord::Migration[4.2]
  def change
    remove_column :usda_weights, :id

    change_table :usda_weights do |t|
      t.remove_index :nutrient_databank_number

      t.index [
        :nutrient_databank_number,
        :sequence_number
      ], {
        unique: true,
        name: "index_usda_weights_on_unique_keys"
      }
    end
  end
end
