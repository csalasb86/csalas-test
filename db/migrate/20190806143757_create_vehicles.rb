class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles do |t|
      t.float :capacity
      t.references :load_type, foreign_key: true

      t.timestamps
    end
  end
end
