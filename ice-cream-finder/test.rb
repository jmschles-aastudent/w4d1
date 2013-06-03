require 'addressable/uri'
require 'json'
require 'rest-client'
require 'nokogiri'

class IceCreamFinder
  attr_reader :origin

  API_KEY = "AIzaSyDMrQnUwbtDMoyZZjyfrup6tRX6Gx-3pQs"
  KEYWORD = "ice cream"
  TYPE = "food"

  def initialize(origin)
    # origin = "160 Folsom Street, San Francisco"
    @origin = origin
  end

  def find_ice_cream
    lat, lng = convert_to_coords(origin)
    places = nearby_places(lat, lng)

    places.each do |(name, destination)|
      puts "#{name}:"
      directions = directions_str(origin, destination)
      puts "#{directions}"
      # legs = routes[0]["legs"]
      # legs.each do |leg|
      #   steps = leg["steps"]
      #   steps.each do |step|
      #     html = step["html_instructions"]
      #     div = '<div style="font-size:0.9em">'
      #     html = html.gsub(div, "#{div}\n")
      #     parsed_html = Nokogiri::HTML(html)
      #     puts parsed_html.text
      #     # puts html
      #   end
      # end
    end
  end

  def convert_to_coords(address)
    url = Addressable::URI.new(
       :scheme => "http",
       :host => "maps.googleapis.com",
       :path => "maps/api/geocode/json",
       :query_values => {
          :address => address,
          :sensor => true
        }).to_s

    response = RestClient.get(url)
    json = JSON.parse(response)
    lat = json["results"][0]["geometry"]["location"]["lat"]
    lng = json["results"][0]["geometry"]["location"]["lng"]
    [lat, lng]
  end

  def nearby_places(lat, lng)
    url = Addressable::URI.new(
       :scheme => "https",
       :host => "maps.googleapis.com",
       :path => "maps/api/place/nearbysearch/json",
       :query_values => {
          :location => "#{lat},#{lng}",
          :radius => 500,
          :sensor => false,
          :keyword => KEYWORD,
          :type => TYPE,
          :key => API_KEY
        }
     ).to_s

    response = RestClient.get(url)
    json = JSON.parse(response)

    destinations = {}
    results = json["results"]
    results.each do |result|
      name = result["name"]
      address = result["vicinity"]
      destinations[name] = address
      # puts result["name"]
      # destinations << result["vicinity"]
    end
    destinations
  end

  def directions_str(origin, destination)
    url = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => {
         :origin => origin,
         :destination => destination,
         :sensor => false,
       }).to_s

    response = RestClient.get(url)
    json = JSON.parse(response)
    routes = json["routes"]
    legs = routes[0]["legs"]
    directions = []
    legs.each do |leg|
      steps = leg["steps"]
         steps.each do |step|
         html = step["html_instructions"]
         div = '<div style="font-size:0.9em">'
         html = html.gsub(div, "#{div}\n\t")
         parsed_html = Nokogiri::HTML(html)
         directions << "\t#{parsed_html.text}"
       # puts html
      end
    end
    directions.join"\n"
  end

end

finder = IceCreamFinder.new("160 Folsom Street, San Francisco")
finder.find_ice_cream



# puts url

# url = "http://maps.googleapis.com/maps/api/geocode/json?address=160+folsom+street,+san+francisco&sensor=true"


# puts lat
# puts lng

# puts json["results"]["geometry"]

# keyword = "ice cream"
# type = "food"
#
# url = Addressable::URI.new(
#    :scheme => "https",
#    :host => "maps.googleapis.com",
#    :path => "maps/api/place/nearbysearch/json",
#    :query_values => {
#       :location => "#{lat},#{lng}",
#       :radius => 500,
#       :sensor => false,
#       :keyword => keyword,
#       :type => type,
#       :key => API_KEY
#     }
#  ).to_s
#
# response = RestClient.get(url)
# json = JSON.parse(response)
#
# results = json["results"]
# results.each do |result|
#   puts result["name"]
#   destination = result["vicinity"]
#   puts "Directions:"
#   show_directions(origin, destination)
#   puts
# end
#
# destination = results[0]["vicinity"]

# http://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&sensor=false


# directions =
# puts json
