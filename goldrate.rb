require 'sinatra/base'

module GoldRate

require 'yaml/store'

def get_db(dbname, group)
  store = YAML::Store.new(dbname)
  store.transaction{store[group]}
end


end




  