class CreateNutrients < ActiveRecord::Migration[5.1]
  def change
    create_table :nutrients do |t|
      t.string :name
      t.string :dnbo
      t.string :key

      t.timestamps
    end
  end
end
