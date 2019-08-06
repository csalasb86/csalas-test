class Driver < ApplicationRecord
  belongs_to :vehicle
  has_many :routes
end
