require 'sinatra/base'

# Array of prices per probe 585, 750,etc. USD
    def probe_arr(gold_price, arr_probe)
      gramm_price = gold_price / 31.103
      arr_probe.map { |probe| [probe, (gramm_price * probe).to_f.round(2)] }
    end

module GetRate

require 'net/http'
require 'nokogiri'
require 'mechanize'
require 'json'
require 'redis'

exch_url = URI("https://openexchangerates.org/api/latest.json?app_id=#{ENV['EXCH_API_ID']}")
gold_url = 'http://www.kitco.com/charts/livegold.html'

mark_gold = [0.375, 0.583, 0.585, 0.750, 0.916, 0.999]
currency_symbol = ["KZT", "KGS", "RUB", "BYN", "AZN", "AMD", "UZS", "UAH", "TJS", "TMT", "USD"]
@store = Redis.new(:url => ENV["REDISCLOUD_URL"])
rates = JSON.parse(Net::HTTP.get(exch_url))

# Let's get gold price!
agent = Mechanize.new
gold = agent.get(gold_url)
html_gold = Nokogiri::HTML(gold.body, 'UTF-8')
  html_gold.css('div.content-blk span#sp-bid').each do |elt|
    @gold_value = elt.text.strip.delete(',').to_f.round(2)     
  end

#Set currency value from json
currency_symbol.each do |sym|
  @store.hset(sym, :currency, rates["rates"][sym].to_f.round(2))
  @store.hset(sym, :gold_value, @gold_value)
  @store.hset(sym, :url, sym)
end

# Local prices for each marking probe of gold
usd_rate = probe_arr(@gold_value, mark_gold).to_h
  usd_rate.each do |key, value|
    currency_symbol.each do |sym|
    @store.hset(sym, :"#{key}", (value * rates["rates"][sym].to_f).round(2))
    end     
    @store.hset("USD", key, value)
end

puts 'Done!'
end
