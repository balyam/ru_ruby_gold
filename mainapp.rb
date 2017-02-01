
require 'sinatra/base'

class MainApp < Sinatra::Base
require 'yaml/store'
require_relative './helpers/goldrate'
helpers GoldRate

  get '/' do
	@price = get_db("db.yml", "KZT")
    erb :index
  end

  get '/kgz' do 
  	@price = get_db("db.yml", "KGS")
  	erb :kgz
  end

end


