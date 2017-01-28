
require 'sinatra/base'

class MainApp < Sinatra::Base

	require 'yaml/store'

  get '/' do
  	store = YAML::Store.new('db.yml')
  	@price = store.transaction{store["rate"]}

     erb :index

  end
  puts @price

end


