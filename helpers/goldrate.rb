require 'sinatra/base'

module Sinatra
  module GoldRate
    require 'redis'

    # Get hash of values for different currency(group)
    def get_db(obj, currency)
      obj.hgetall(currency)
    end

    def url_valid?(url, yaml_store)
      yaml_store.key?(url.upcase)
    end
  end
  helpers GoldRate
end
