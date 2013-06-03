require 'addressable/uri'
require 'json'
require 'rest-client'
require 'nokogiri'

api_key = "AIzaSyDMrQnUwbtDMoyZZjyfrup6tRX6Gx-3pQs"
"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=harbour&sensor=false&key=#{api_key}"



origin = "160 Folsom Street, San Francisco"
url = Addressable::URI.new(
   :scheme => "http",
   :host => "maps.googleapis.com",
   :path => "maps/api/geocode/json",
   :query_values => {
      :address => origin,
      :sensor => true
    }
 ).to_s

 def show_directions(origin, destination)

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
   legs.each do |leg|
     steps = leg["steps"]
     steps.each do |step|
       html = step["html_instructions"]
       div = '<div style="font-size:0.9em">'
       html = html.gsub(div, "#{div}\n")
       parsed_html = Nokogiri::HTML(html)
       puts parsed_html.text
       # puts html
     end
   end
 end

# puts url

# url = "http://maps.googleapis.com/maps/api/geocode/json?address=160+folsom+street,+san+francisco&sensor=true"
response = RestClient.get(url)
json = JSON.parse(response)
lat = json["results"][0]["geometry"]["location"]["lat"]
lng = json["results"][0]["geometry"]["location"]["lng"]

# puts lat
# puts lng

# puts json["results"]["geometry"]

keyword = "ice cream"
type = "food"

url = Addressable::URI.new(
   :scheme => "https",
   :host => "maps.googleapis.com",
   :path => "maps/api/place/nearbysearch/json",
   :query_values => {
      :location => "#{lat},#{lng}",
      :radius => 500,
      :sensor => false,
      :keyword => keyword,
      :type => type,
      :key => api_key
    }
 ).to_s

response = RestClient.get(url)
json = JSON.parse(response)

results = json["results"]
results.each do |result|
  puts result["name"]
  destination = result["vicinity"]
  puts "Directions:"
  show_directions(origin, destination)
  puts
end

destination = results[0]["vicinity"]

# http://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&sensor=false


# directions =
# puts json
