
require 'sinatra/base'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base
require 'yaml/store'
helpers Sinatra::GoldRate

  get '/' do
    @price = get_db("db.yml", "KZT")
    erb :index
  end

  get '/kgz' do
    @price = get_db("db.yml", "KGS")
    erb :kgz
  end
end
