require 'sinatra/base'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base

helpers Sinatra::GoldRate

  get '/' do
    @price = get_db("KZT")
    erb :index
  end

  get '/kgz' do
    @price = get_db("KGS")
    erb :kgz
  end
end
