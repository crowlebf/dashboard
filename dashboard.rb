require "./lib/geolocation"
require "sinatra/base"
require "net/http"
require "json"

require "dotenv"
Dotenv.load

class Dashboard < Sinatra::Base
  get("/") do
    @ip = request.ip
    @geolocation = Geolocation.new(@ip)
    erb :dashboard
  end

  get("/weather") do
    @ip = request.ip
    @geolocation = Geolocation.new(@ip)
    key = ENV["DARK_SKY_API_KEY"]
    uri = URI("https://api.forecast.io/forecast/#{key}/#{@geolocation.latitude},#{@geolocation.longitude}")
    data = Net::HTTP.get(uri)
    @weather = JSON.parse(data)
    erb :weather
  end

  get("/news") do
    key = ENV["NYT_API_KEY"]
    uri = URI("http://api.nytimes.com/svc/topstories/v1/national.json?api-key=#{key}")
    data = Net::HTTP.get(uri)
    @news = JSON.parse(data)
    erb :news
  end

  get("/events") do
    @ip = request.ip
    @geolocation = Geolocation.new(@ip)
    uri = URI('http://api.seatgeek.com/2/events?venue.city=Boston&venue.state=MA')
    data = Net::HTTP.get_response(uri)
    @events = JSON.parse(data.body)["events"]
    erb :events
  end
end
