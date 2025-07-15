# frozen_string_literal: true

class Vehicle < ApplicationRecord
  belongs_to :load_type, optional: true
end
