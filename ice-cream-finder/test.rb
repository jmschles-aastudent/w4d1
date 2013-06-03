require 'addressable/uri'
require 'json'
require 'rest-client'

address = "160 Folsom Street, San Francisco"
url = Addressable::URI.new(
   :scheme => "http",
   :host => "maps.googleapis.com",
   :path => "maps/api/geocode/json",
   :query_values => {
      :address => address,
      :sensor => true
    }
 ).to_s

puts url

url = "http://maps.googleapis.com/maps/api/geocode/json?address=160+folsom+street,+san+francisco&sensor=true"
response = RestClient.get(url)
json = JSON.parse(response)
lat = json["results"][0]["geometry"]["location"]["lat"]
lng = json["results"][0]["geometry"]["location"]["lng"]

puts lat
puts lng

# puts json["results"]["geometry"]
