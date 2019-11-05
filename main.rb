# source: https://fire.ca.gov/incidents/2019/
# pulled from https://fire.ca.gov/umbraco/Api/IncidentApi/GetIncidents?year=2019

require "json"
require "hashie"
require "active_support/all"

class Fire < Hashie::Mash
  def initialize(hash)
    super(
      hash.dup.transform_keys { |k| k.underscore }
    )
  end
end

class County
  attr_accessor :fires, :name

  def initialize(name)
    @name = name
    @fires = []
  end

  def add_fire(fire)
    @fires << fire if fire.present?
  end

  def total_acres_burned
    fires.map { |fire| fire.acres_burned || 0 }.reduce(&:+)
  end
end

file_data = File.read("./ca-fire-data-11-4-2019.json")
fire_table = JSON.parse(file_data)["Incidents"].map { |fire| Fire.new(fire) }

all_counties_table = {}
fire_table.each do |fire|
  next unless fire.counties.present?
  fire.counties.each do |county_name|
    all_counties_table[county_name] ||= County.new(county_name)
    all_counties_table[county_name].add_fire(fire)
  end
end

all_counties_table = all_counties_table.sort_by { |k, v| -v.total_acres_burned }.to_h

core_counties_list = [
  "San Bernardino",
  "Riverside",
  "Los Angeles",
  "San Joaquin",
  "San Diego",
  "Fresno"
]

core_counties_table = all_counties_table.select { |k, v| k.in?(core_counties_list) }

puts "\n\nCore County Totals:".upcase
index = 1
core_counties_table.each do |_, county|
  puts "#{index}. #{county.name}: #{county.total_acres_burned}"
  index += 1
end
grand_total = core_counties_table.map { |_, county| county.total_acres_burned }.reduce(&:+)
puts "TOTAL ACRES BURNED: #{grand_total}"

puts "\n\nAll County Totals:".upcase
index = 1
all_counties_table.each do |_, county|
  puts "#{index}. #{county.name}: #{county.total_acres_burned}"
  index += 1
end
grand_total = all_counties_table.map { |_, county| county.total_acres_burned }.reduce(&:+)
puts "TOTAL ACRES BURNED: #{grand_total}"
