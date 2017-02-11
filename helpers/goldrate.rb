require 'sinatra/base'

module Sinatra
  module GoldRate
    require 'yaml/store'

    # Get hash of values for different currency(group)
    def get_db(dbname, group)
      store = YAML::Store.new(dbname)
      store.transaction { store[group] }
    end    
  end
  helpers GoldRate
end
