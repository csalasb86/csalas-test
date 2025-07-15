# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

tables_with_seeds = []

puts 'Cargando o actualizando tipos de carga'
[
  { id: 1, name: 'General' },
  { id: 2, name: 'Refrigerada' }
].each do |attrs|
  load_type = LoadType.find_or_initialize_by(id: attrs[:id])
  load_type.update({ name: attrs[:name] })
end
tables_with_seeds << 'load_types'

puts 'Cargando Vehiculos'
[
  { id: 1, capacity: 500, load_type_id: 2 },
  { id: 2, capacity: 1000, load_type_id: 1 },
  { id: 3, capacity: 550, load_type_id: 1 },
  { id: 4, capacity: 1000, load_type_id: 2 }
].each do |attrs|
  load_type = Vehicle.find_or_initialize_by(id: attrs[:id])
  load_type.update({
                     capacity: attrs[:capacity],
                     load_type_id: attrs[:load_type_id]
                   })
end
tables_with_seeds << 'vehicles'

puts 'Cargando Conductores'
[
  { id: 1, name: 'Tom Araya', phone: '666666666', cities: %w[Santiago Vitacura], max_stops_amount: 10 },
  { id: 2, name: 'Dave Mustaine', phone: nil, cities: ['San Bernardo', 'Santiago', 'Maipu'], max_stops_amount: 10 },
  { id: 3, name: 'James Hetfield', phone: nil, cities: ['Las Condes', 'Vitacura', 'Huechuraba'], max_stops_amount: 50 },
  { id: 4, name: 'Scott Ian', phone: nil, cities: ['Providencia'], max_stops_amount: 1 }
].each do |attrs|
  load_type = Driver.find_or_initialize_by(id: attrs[:id])
  load_type.update!({
                      name: attrs[:name],
                      phone: attrs[:phone],
                      cities: attrs[:cities],
                      max_stops_amount: attrs[:max_stops_amount]
                    })
end
tables_with_seeds << 'drivers'

puts 'Asignando conductores a vehiculos y viceversa'
Driver.find(1).update({ vehicle_id: 3 })
Vehicle.find(3).update({ driver_id: 1 })

puts 'Cargando Rutas'
[
  { id: 1, starts_at: DateTime.parse("#{Time.zone.today} 09:00:00"), ends_at: DateTime.parse("#{Time.zone.today} 10:00:00"),
    load_type_id: LoadType::GENERAL, load_sum: 50, cities: ['Santiago'], stops_amount: 2 },
  { id: 2, starts_at: DateTime.parse("#{Time.zone.today} 09:00:00"), ends_at: DateTime.parse("#{Time.zone.today} 11:00:00"),
    load_type_id: LoadType::GENERAL, load_sum: 100, cities: ['Huechuraba'], stops_amount: 5 },
  { id: 3, starts_at: DateTime.parse("#{Time.zone.today} 10:35:00"), ends_at: DateTime.parse("#{Time.zone.today} 13:24:00"),
    load_type_id: LoadType::GENERAL, load_sum: 460, cities: ['Santiago', 'Las Condes'], stops_amount: 4 },
  { id: 4, starts_at: DateTime.parse("#{Time.zone.today} 12:58:00"), ends_at: DateTime.parse("#{Time.zone.today} 14:00:00"),
    load_type_id: LoadType::REFRIGERADA, load_sum: 500, cities: ['Maipu'], stops_amount: 10 },
  { id: 5, starts_at: DateTime.parse("#{Time.zone.today} 08:30:00"), ends_at: DateTime.parse("#{Time.zone.today} 18:20:00"),
    load_type_id: LoadType::REFRIGERADA, load_sum: 1000, cities: ['Providencia'], stops_amount: 1 }
].each do |attrs|
  load_type = Route.find_or_initialize_by(id: attrs[:id])
  load_type.update!({
                      starts_at: attrs[:starts_at],
                      ends_at: attrs[:ends_at],
                      load_type_id: attrs[:load_type_id],
                      load_sum: attrs[:load_sum],
                      cities: attrs[:cities],
                      stops_amount: attrs[:stops_amount]
                    })
end
tables_with_seeds << 'routes'

puts 'Verificando y reseteando secuencias'
tables_with_seeds.each do |table|
  result = begin
    ActiveRecord::Base.connection.execute("SELECT id FROM #{table} ORDER BY id DESC LIMIT 1")
  rescue StandardError
    (puts "Warning: not procesing table #{table}. Id is missing?"

     next)
  end
  ai_val = result.any? ? result.first['id'].to_i + 1 : 1
  puts "Resetting auto increment ID for #{table} to #{ai_val}"
  ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH #{ai_val}")
end
