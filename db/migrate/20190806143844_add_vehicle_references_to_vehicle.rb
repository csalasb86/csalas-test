class AddVehicleReferencesToVehicle < ActiveRecord::Migration[5.2]
  def change
    add_reference :vehicles, :driver, foreign_key: true
  end
end
