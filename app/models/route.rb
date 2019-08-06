class Route < ApplicationRecord
  belongs_to :load_type
  belongs_to :driver
  belongs_to :vehicle

  scope :unassigned, -> { 
    where(vehicle_id: nil).where(driver_id: nil)
    .where("starts_at >= ?", DateTime.now.in_time_zone(Time.zone).beginning_of_day)
    .where("ends_at <= ?", DateTime.now.in_time_zone(Time.zone).end_of_day)
    .order(:ends_at)
  }

  scope :unfinished, lambda { | ends_at |
    where.not(vehicle_id: nil).where.not(driver_id: nil)
    .where("starts_at >= ?", DateTime.now.in_time_zone(Time.zone).beginning_of_day)
    .where("ends_at > ?", DateTime.now.in_time_zone(Time.zone))
  }

  # rutas asignadas y terminadas
  scope :finished, lambda { | ends_at |
    where.not(vehicle_id: nil).where.not(driver_id: nil)
    .where("starts_at >= ?", DateTime.now.in_time_zone(Time.zone).beginning_of_day)
    .where("ends_at <= ?", DateTime.now.in_time_zone(Time.zone))
    # .where("ends_at <= ?", ends_at)
  }
end
