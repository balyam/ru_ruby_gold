require 'sinatra/base'

module Sinatra
  module GoldRate
    require 'redis'

    # Get hash of values for different currency(group)
    def get_db(obj, currency)
      obj.hgetall(currency)
    end    
  end
  helpers GoldRate
end
