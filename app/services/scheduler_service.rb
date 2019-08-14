class SchedulerService < ApplicationService

  def call
    Route.unassigned.each do | route |
      driver_id = nil
      vehicle_id = nil

      # buscar conductores disponibles
        # si hay rutas asignadas, consultar todos los drivers asignados cuya ruta haya terminado (ends_at de la ruta asignada sea menor a ends_at de route)
        # verificar que el cities este encluido en el cities de driver
        # verificar que el max_stops_amount del driver sea mayor o igual al stops_amount de la ruta
        # si no tiene vehicle propio asignarle uno
      drivers = get_drivers(route)

      # buscar vehicles disponibles
        # verificar que el load_type de vehicle sea igual al load_type de route
        # verificar que la capacity de vehicle sea mayor o igual a load_sum de route
      if drivers.count > 0
        drivers.each do | driver |
          vehicle_id = nil
          # si el driver tiene vehicle y cumple con los requisitos lo asignamos
          vehicle = nil
          driver_today_vehicle = get_driver_today_vehicle(route, driver)
          if !driver_today_vehicle.blank?
            vehicle = Vehicle.find(driver_today_vehicle)
          elsif !driver.vehicle.blank?
            vehicle = driver.vehicle  
          end

          if !vehicle.blank?
            if vehicle.load_type_id == route.load_type_id && vehicle.capacity >= route.load_sum
              driver_id = driver.id
              vehicle_id = vehicle.id
            end
          else
            vehicles = get_vehicles(route)
            
            if vehicles.count > 0
              vehicles.each do | vehicle |
                vehicle_not_assigned = Route.assigned_today(vehicle.id, driver.id).count == 0
                puts "driver #{driver.id} verificando vehicle_id #{vehicle.id} vehicle_not_assigned #{vehicle_not_assigned}"
                if vehicle.load_type_id == route.load_type_id && vehicle.capacity >= route.load_sum && vehicle_not_assigned
                  driver_id = driver.id
                  vehicle_id = vehicle.id
                  puts "driver_id #{driver_id} | vehicle_id #{vehicle_id} vehicle_not_assigned NO ASIGNADO" 
                else
                  puts "driver_id #{driver_id} | vehicle_id #{vehicle_id} vehicle_not_assigned YA ASIGNADO" 
                end
              end
            end
          end
          if !driver_id.nil? && !vehicle_id.nil?
            # puts "driver_id #{driver_id} | vehicle_id #{vehicle_id}"
            # vehicle_not_assigned = Route.assigned_today(vehicle_id, driver_id).count == 0
            # puts "vehicle_not_assigned #{vehicle_not_assigned}"
            # if vehicle_not_assigned
            #   route.update({ driver_id: driver_id, vehicle_id: vehicle_id })
            # else
            #   puts "vehiculo ya asignado"
            # end
            route.update({ driver_id: driver_id, vehicle_id: vehicle_id })
            puts "driver_id #{driver_id} | vehicle_id #{vehicle_id} ASIGNADO!" 
          else
            puts "driver_id #{driver_id} | vehicle_id #{vehicle_id} no pudo ser asignado" 
          end
        end
      end
    end
  end

  private
    def get_drivers(route)
      driver_ids = []
      driver_ids_finished = []

      # la primera vez
      driver_ids << Driver.where('cities && ARRAY[?]', route.cities)
        .where("max_stops_amount >= ?", route.stops_amount)
        .pluck(:id)

      # liberar drivers con rutas ya terminadas y que cumplan los requisitos
      finished_routes = Route.finished
      unless finished_routes.blank?
        driver_ids_finished << Driver.where(id: finished_routes.pluck(:driver_id))
          .where('cities && ARRAY[?]', route.cities)
          .where("max_stops_amount >= ?", route.stops_amount)
          .pluck(:id)
        driver_ids = (driver_ids + driver_ids_finished).flatten
      end

      # descartar drivers con rutas no terminadas
      unfinished_routes = Route.unfinished
      unless unfinished_routes.blank?
        driver_ids_unfinished = unfinished_routes.pluck(:driver_id)
        puts "driver_ids #{driver_ids}"
        puts "driver_ids_unfinished #{driver_ids_unfinished}"
        driver_ids = driver_ids.reject {|d| driver_ids_unfinished.include? d}
        puts "driver_ids #{driver_ids}"
      end

      Driver.where(id: driver_ids)
    end

    def get_vehicles(route)
      vehicle_ids = []
      vehicle_ids_finished = []

      # la primera vez
      vehicle_ids = Vehicle.where(driver_id: nil).where(load_type_id: route.load_type_id)
        .where("capacity >= ?", route.load_sum).pluck(:id)
     
      # liberar vehicles con rutas ya terminadas y que cumplan los requisitos
      finished_routes = Route.finished
      unless finished_routes.blank?
        # vehicle_ids_finished << Vehicle.where(driver_id: nil).where(load_type_id: route.load_type_id)
        #   .where("capacity >= ?", route.load_sum).pluck(:id)
        vehicle_ids_finished << Vehicle.where(id: finished_routes.pluck(:vehicle_id))
          .where(driver_id: nil).where(load_type_id: route.load_type_id)
          .where("capacity >= ?", route.load_sum)
          .pluck(:id)
        vehicle_ids = (vehicle_ids + vehicle_ids_finished).flatten
      end

      # descartar drivers con rutas no terminadas
      unfinished_routes = Route.unfinished
      unless unfinished_routes.blank?
        vehicle_ids_unfinished = unfinished_routes.pluck(:vehicle_id)
        puts "vehicle_ids #{vehicle_ids}"
        puts "vehicle_ids_unfinished #{vehicle_ids_unfinished}"
        vehicle_ids = vehicle_ids.reject {|d| vehicle_ids_unfinished.include? d}
        puts "vehicle_ids #{vehicle_ids}"
      end

      Vehicle.where(id: vehicle_ids)
    end

    def get_driver_today_vehicle(route, driver)
      vehicle_id = nil
      last_finished_route = Route.finished.where(driver_id: driver.id).last
      vehicle_id = last_finished_route.vehicle_id unless last_finished_route.nil?
      vehicle_id
    end
end