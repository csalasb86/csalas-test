class AddCitiesToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :cities, :text, array: true, default: []
  end
end
