# frozen_string_literal: true

class Driver < ApplicationRecord
  belongs_to :vehicle, optional: true
  has_many :routes, dependent: :destroy
end
