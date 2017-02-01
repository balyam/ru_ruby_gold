require 'sinatra/base'

module Sinatra

module GoldRate

require 'yaml/store'

#Get hash of values for different currency(group)
def get_db(dbname, group)
  store = YAML::Store.new(dbname)
  store.transaction{store[group]}
end

#Array of prices per probe 585, 750,etc. USD
def probe_arr(gold_price, arr_probe)
   gramm_price = gold_price/31.103
   arr_probe.map { |probe| [probe, (gramm_price * probe).to_f.round(2)] }
end

end
helpers GoldRate
end