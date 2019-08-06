class AddMaxStopsAmountToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :max_stops_amount, :integer
  end
end
