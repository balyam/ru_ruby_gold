require 'sinatra/base'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base

helpers Sinatra::GoldRate

store = Redis.new(:url => ENV["REDISCLOUD_URL"])

  get '/' do
    @price = get_db(store, "KZT")
    erb :index
  end

  get '/kgz' do
    @price = get_db(store, "KGS")
    erb :kgz
  end

  get '/rub' do
  	@price = get_db(store, "RUB")
  	erb :rus
  end
end
