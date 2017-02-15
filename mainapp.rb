require 'sinatra/base'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base

helpers Sinatra::GoldRate

store = Redis.new(:url => ENV["REDISCLOUD_URL"])

before do
@curr_symbols = ["KZT", "KGS", "RUB", "BYN", "AZN", "AMD", "UZS", "UAH", "TJS", "USD"]
end

  get '/' do    
    @price = get_db(store, "KZT")    
    erb :index
  end

  get '/:url' do
    @price = get_db(store, params[:url].upcase)
    erb :rub
  end

end
