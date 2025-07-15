# frozen_string_literal: true

class SchedulerService < ApplicationService
  def call
    Route.unassigned.each do |route|
      driver_id = nil
      vehicle_id = nil

      # buscar conductores disponibles
      # si hay rutas asignadas, consultar todos los drivers asignados cuya ruta haya terminado
      # (ends_at de la ruta asignada sea menor a ends_at de route)
      # verificar que el cities este encluido en el cities de driver
      # verificar que el max_stops_amount del driver sea mayor o igual al stops_amount de la ruta
      # si no tiene vehicle propio asignarle uno
      drivers = get_drivers(route)

      # buscar vehicles disponibles
      # verificar que el load_type de vehicle sea igual al load_type de route
      # verificar que la capacity de vehicle sea mayor o igual a load_sum de route
      next unless drivers.any?

      drivers.each do |driver|
        vehicle_id = nil
        # si el driver tiene vehicle y cumple con los requisitos lo asignamos
        vehicle = nil
        driver_today_vehicle = get_driver_today_vehicle(route, driver)
        if driver_today_vehicle.present?
          vehicle = Vehicle.find(driver_today_vehicle)
        elsif driver.vehicle.present?
          vehicle = driver.vehicle
        end

        if vehicle.present?
          if vehicle.load_type_id == route.load_type_id && vehicle.capacity >= route.load_sum
            driver_id = driver.id
            vehicle_id = vehicle.id
          end
        else
          vehicles = get_vehicles(route)

          if vehicles.any?
            vehicles.each do |vehicle|
              vehicle_not_assigned = Route.assigned_today(vehicle.id, driver.id).none?
              next unless vehicle.load_type_id == route.load_type_id &&
                          vehicle.capacity >= route.load_sum &&
                          vehicle_not_assigned

              driver_id = driver.id
              vehicle_id = vehicle.id
            end
          end
        end
        route.update({ driver_id: driver_id, vehicle_id: vehicle_id }) if !driver_id.nil? && !vehicle_id.nil?
      end
    end
  end

  private

  def get_drivers(route)
    driver_ids = []
    driver_ids_finished = []

    # la primera vez
    driver_ids << Driver.where('cities && ARRAY[?]', route.cities)
                        .where(max_stops_amount: route.stops_amount..)
                        .pluck(:id)

    # liberar drivers con rutas ya terminadas y que cumplan los requisitos
    finished_routes = Route.finished.where.not(starts_at: route.starts_at)
    if finished_routes.present?
      driver_ids_finished << Driver.where(id: finished_routes.pluck(:driver_id))
                                   .where('cities && ARRAY[?]', route.cities)
                                   .where(max_stops_amount: route.stops_amount..)
                                   .pluck(:id)
      driver_ids = (driver_ids + driver_ids_finished).flatten
    end

    # descartar drivers con rutas igual hora de inicio
    finished_routes_same_start = Route.finished.where(starts_at: route.starts_at)
    if finished_routes_same_start.present?
      driver_ids = driver_ids.reject { |d| finished_routes_same_start.pluck(:driver_id).include? d }
    end

    # descartar drivers con rutas no terminadas
    unfinished_routes = Route.unfinished
    if unfinished_routes.present?
      driver_ids_unfinished = unfinished_routes.pluck(:driver_id)
      driver_ids = driver_ids.reject { |d| driver_ids_unfinished.include? d }
    end

    Driver.where(id: driver_ids)
  end

  def get_vehicles(route)
    vehicle_ids_finished = []

    # la primera vez
    vehicle_ids = Vehicle.where(driver_id: nil).where(load_type_id: route.load_type_id)
                         .where(capacity: route.load_sum..).pluck(:id)

    # liberar vehicles con rutas ya terminadas y que cumplan los requisitos
    finished_routes = Route.finished
    if finished_routes.present?
      vehicle_ids_finished << Vehicle.where(id: finished_routes.pluck(:vehicle_id))
                                     .where(driver_id: nil).where(load_type_id: route.load_type_id)
                                     .where(capacity: route.load_sum..)
                                     .pluck(:id)
      vehicle_ids = (vehicle_ids + vehicle_ids_finished).flatten
    end

    # descartar drivers con rutas no terminadas
    unfinished_routes = Route.unfinished
    if unfinished_routes.present?
      vehicle_ids_unfinished = unfinished_routes.pluck(:vehicle_id)
      vehicle_ids = vehicle_ids.reject { |d| vehicle_ids_unfinished.include? d }
    end

    Vehicle.where(id: vehicle_ids)
  end

  def get_driver_today_vehicle(_route, driver)
    vehicle_id = nil
    last_finished_route = Route.finished.where(driver_id: driver.id).last
    vehicle_id = last_finished_route.vehicle_id unless last_finished_route.nil?
    vehicle_id
  end
end
