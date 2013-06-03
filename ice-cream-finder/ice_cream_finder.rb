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
    @origin = origin
  end

  def nearby_directions
    lat, lng = convert_to_coords(origin)
    places = nearby_places(lat, lng)

    places.each do |(name, destination)|
      puts "#{name}:"
      directions = directions_str(origin, destination)
      puts "#{directions}"
    end
  end

  private
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
      end
    end
    directions.join"\n"
  end
end

finder = IceCreamFinder.new("160 Folsom Street, San Francisco")
finder.nearby_directions
