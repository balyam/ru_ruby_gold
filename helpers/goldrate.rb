require 'sinatra/base'

module Sinatra
  module GoldRate
    require 'redis'

    # Get hash of values for different currency(group)
    def get_db(group)
      store = Redis.new(:url => ENV["REDISCLOUD_URL"])
      store.hgetall(group)
    end    
  end
  helpers GoldRate
end
