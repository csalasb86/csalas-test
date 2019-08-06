class CreateDrivers < ActiveRecord::Migration[5.2]
  def change
    create_table :drivers do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.references :vehicle, foreign_key: true

      t.timestamps
    end
  end
end
