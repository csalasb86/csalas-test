class SchedulerService < ApplicationService
  # attr_reader :route
  
  # def initialize(params = nil)
  #   # @route = params[:route]
  # end

  def call
    # today = Date.today
    # drivers = get_drivers
    # vehicles = get_vehicles
    Route.unassigned.each do | route |
      driver_id = nil
      vehicle_id = nil
      puts "****** asignando driver al route #{route.id}"
      # cities = route.cities
      # drivers = Driver.where("? = ANY(cities)", cities)
      # puts "drivers #{drivers.inspect}"

      # buscar conductores disponibles
        # si hay rutas asignadas, consultar todos los drivers asignados cuya ruta haya terminado (ends_at de la ruta asignada sea menor a ends_at de route)
        # verificar que el cities este encluido en el cities de driver
        # verificar que el max_stops_amount del driver sea mayor o igual al stops_amount de la ruta
        # si no tiene vehicle propio asignarle uno
      drivers = get_drivers(route)
      # puts "drivers #{drivers}"

      # buscar vehicles disponibles
        # verificar que el load_type de vehicle sea igual al load_type de route
        # verificar que la capacity de vehicle sea mayor o igual a load_sum de route
      if drivers.count > 0
        drivers.each do | driver |
          puts "bsucando vehicle para driver #{driver.id}"
          # si el driver tiene vehicle y cumple con los requisitos lo asignamos
          vehicle = nil
          driver_today_vehicle = get_driver_today_vehicle(route, driver)
          if !driver_today_vehicle.blank?
            vehicle = Vehicle.find(driver_today_vehicle)
          elsif !driver.vehicle.blank?
            vehicle = driver.vehicle  
          end
          if !vehicle.blank?
            puts "driver #{driver.id} tiene el vehicle #{vehicle.id}"
            if vehicle.load_type_id == route.load_type_id && vehicle.capacity >= route.load_sum
              puts "el vehicle #{vehicle.id} cumple con los requisitos"
              driver_id = driver.id
              vehicle_id = vehicle.id
            else
              puts "el vehicle #{vehicle.id} NO cumple con los requisitos, no podemos asignar driver"
            end
          else
            puts "driver #{driver.id} no tiene vehicle, le asignamos el que cumpla con los requisitos y no este asignado a otro driver"
            vehicles = get_vehicles(route)
            # driver_today_vehicle = get_driver_today_vehicle(route, driver)
            # puts "driver_today_vehicle #{driver_today_vehicle}"
            if vehicles.count > 0
              puts "vehicles disponibles #{vehicles.pluck(:id)}"
              vehicles.each do | vehicle |
                if vehicle.load_type_id == route.load_type_id && vehicle.capacity >= route.load_sum
                  puts "el vehicle #{vehicle.id} cumple con los requisitos"
                  driver_id = driver.id
                  vehicle_id = vehicle.id
                else
                  puts "el vehicle #{vehicle.id} NO cumple con los requisitos, no podemos asignar driver"
                end
              end
            else
              puts "no hay vehicles disponibles"
            end
          end
          # puts "******** driver_id #{driver_id} vehicle_id #{vehicle_id}"
          if !driver_id.nil? && !vehicle_id.nil?
            puts "asignamos el driver #{driver_id} y el vehicle #{vehicle_id}"
            route.update({ driver_id: driver_id, vehicle_id: vehicle_id })
          else
            puts "route sin asignacion, no encontramos el driver o el vehicle necesario"
          end
        end
      end
    end
  end

  private
    def get_drivers(route)
      driver_ids = []
      driver_ids_finished = []

      # liberar drivers con rutas ya terminadas y que cumplan los requisitos
      finished_routes = Route.finished(route.ends_at)
      unless finished_routes.blank?
        driver_ids_finished << Driver.where(id: finished_routes.pluck(:driver_id))
          .where('cities && ARRAY[?]', route.cities)
          .where("max_stops_amount >= ?", route.stops_amount)
          .pluck(:id)
      end
      # puts "driver_ids_finished #{driver_ids_finished}"

      # la primera vez
      driver_ids << Driver.where('cities && ARRAY[?]', route.cities)
        .where("max_stops_amount >= ?", route.stops_amount)
        .pluck(:id)

      driver_ids = (driver_ids + driver_ids_finished).flatten
      # puts "driver_ids #{driver_ids}"
      Driver.where(id: driver_ids)
    end

    def get_vehicles(route)
      vehicle_ids = []
      vehicle_ids_finished = []

      # la primera vez
      vehicle_ids = Vehicle.where(driver_id: nil).where(load_type_id: route.load_type_id)
        .where("capacity >= ?", route.load_sum).pluck(:id)
     
      # liberar vehicles con rutas ya terminadas y que cumplan los requisitos
      finished_routes = Route.finished(route.ends_at)
      unless finished_routes.blank?
        vehicle_ids_finished << Vehicle.where(driver_id: nil).where(load_type_id: route.load_type_id)
          .where("capacity >= ?", route.load_sum).pluck(:id)
      end

      vehicle_ids = (vehicle_ids + vehicle_ids_finished).flatten

      Vehicle.where(id: vehicle_ids)
    end

    def get_driver_today_vehicle(route, driver)
      vehicle_id = nil
      last_finished_route = Route.finished(route.ends_at).where(driver_id: driver.id).last
      vehicle_id = last_finished_route.vehicle_id unless last_finished_route.nil?
      vehicle_id
    end
end