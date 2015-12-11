require "./lib/geolocation"
require "sinatra/base"
require "net/http"
require "pry"
require "json"
require "sinatra"
require "pg"

configure :development do
  set :db_config, { dbname: "restaurants" }
end

configure :production do
  uri = URI.parse(ENV["DATABASE_URL"])
  set :db_config, {
    host: uri.host,
    port: uri.port,
    dbname: uri.path.delete('/'),
    user: uri.user,
    password: uri.password
  }
end

def db_connection
  begin
    connection = PG.connect(settings.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

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

