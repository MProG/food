class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :dnbo
      t.string :upc
      t.boolean :imported, default: false

      t.timestamps
    end
  end
end
