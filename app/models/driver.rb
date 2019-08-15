class Driver < ApplicationRecord
  belongs_to :vehicle, optional: true
  has_many :routes
end
