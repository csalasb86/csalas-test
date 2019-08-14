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

  # rutas asignadas y terminadas
  scope :finished, -> { 
    where.not(vehicle_id: nil).where.not(driver_id: nil)
    .where("starts_at >= ?", DateTime.now.in_time_zone(Time.zone).beginning_of_day)
    .where("ends_at <= ?", DateTime.now.in_time_zone(Time.zone))
  }

  scope :assigned_today, lambda { | vehicle_id, driver_id |
    where(vehicle_id: vehicle_id).where.not(driver_id: driver_id)
    .where("starts_at >= ?", DateTime.now.in_time_zone(Time.zone).beginning_of_day)
    .where("ends_at <= ?", DateTime.now.in_time_zone(Time.zone).end_of_day)
  }

  scope :unfinished, -> { 
    where.not(vehicle_id: nil).where.not(driver_id: nil)
    .where("starts_at >= ?", DateTime.now.in_time_zone(Time.zone).beginning_of_day)
    .where("ends_at >= ?", DateTime.parse("2019-08-14 16:00:00"))#DateTime.now.in_time_zone(Time.zone))
  }
end
