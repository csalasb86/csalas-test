# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

tables_with_seeds = []

puts "Cargando o actualizando tipos de carga"
[
  {id: 1, name: 'General'},
  {id: 2, name: 'Refrigerada'}
].each do | attrs |
  load_type = LoadType.find_or_initialize_by(id: attrs[:id]) 
  load_type.update({ name: attrs[:name] })
end
tables_with_seeds << 'load_types'

puts "Verificando y reseteando secuencias"
tables_with_seeds.each do |table|
  result = ActiveRecord::Base.connection.execute("SELECT id FROM #{table} ORDER BY id DESC LIMIT 1") rescue ( puts "Warning: not procesing table #{table}. Id is missing?" ; next )
  ai_val = result.any? ? result.first['id'].to_i + 1 : 1
  puts "Resetting auto increment ID for #{table} to #{ai_val}"
  ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH #{ai_val}")
end