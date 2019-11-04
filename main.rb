# source: https://fire.ca.gov/incidents/2019/
# pulled from https://fire.ca.gov/umbraco/Api/IncidentApi/GetIncidents?year=2019

require "json"

file_data = File.read("./ca-fire-data-11-4-2019.json")
table = JSON.parse(file_data)["Incidents"]

core_counties_list = [
  "San Bernardino",
  "Riverside",
  "Los Angeles",
  "San Joaquin",
  "San Diego",
  "Fresno"
]

core_counties_table = {}
core_counties_list.each { |county| core_counties_table.merge!(county => []) }

table.each do |fire|
  core_counties_table.each do |county, fire_list|
    next unless fire["Counties"].include? county
    fire_list << fire.dup
  end
end

core_counties_table.each do |county, fires|
  total = fires.map { |fire| fire["AcresBurned"] }.compact.reduce(&:+)
  fires << { "Total" => total }
end

puts "\n\nCore County Totals:".upcase
core_counties_table.each do |county, fires|
  puts "#{county}: #{fires.last["Total"]}"
end

all_counties_table = {}
table.each do |fire|
  next unless fire["Counties"] && fire["Counties"].any?
  fire["Counties"].each do |fire_county|
    all_counties_table[fire_county] ||= []
    all_counties_table[fire_county] << fire.dup
  end
end

all_counties_table.each do |county, fires|
  total = fires.map { |fire| (fire["AcresBurned"] || 0) }.compact.reduce(&:+)
  fires << { "Total" => total }
end

puts "\n\nAll County Totals:".upcase
all_counties_table.each do |county, fires|
  puts "#{county}: #{fires.last["Total"]}"
end
