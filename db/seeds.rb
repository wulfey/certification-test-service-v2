# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


test_list = [
  [ "Trucks", "How best to sell trucks to truckanados." ],
  [ "Hybrids", "Efficiency, smugness, or both?" ],
  [ "Supercars", "Ask to see their old car before the test drive." ],
  [ "Sedans", "Only sell to olds." ],
]

test_list.each do |name, description|
  Certtest.create( name: name, description: description )
end
