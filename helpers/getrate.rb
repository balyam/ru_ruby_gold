require 'sinatra/base'

# Array of prices per probe 585, 750,etc. USD
def probe_arr(metal_price, arr_probe)
  gram_price = metal_price / 31.103
  arr_probe.map { |probe| [probe, (gram_price * probe).to_f.round(2)] }
end

# All magic is here
module GetRate
  require 'net/http'
  require 'nokogiri'
  require 'mechanize'
  require 'redis'
  require 'openexchangerates_data'

  gold_url = 'http://www.kitco.com/charts/livegold.html'
  silver_url = 'http://www.kitco.com/charts/livesilver.html'

  mark_gold = [0.375, 0.583, 0.585, 0.750, 0.916, 0.999]
  mark_silver = [1, 1000, 31.1035]
  currency_symbol = %w[KZT KGS RUB BYN AZN UZS UAH AMD GEL MDL TJS TMT]
  @store = Redis.new(url: ENV['REDISCLOUD_URL'])
  rates = OpenexchangeratesData::Client.new.latest

  @last_update = Time.at(rates['timestamp']).strftime("%d-%m-%Y %k:%M")

  # Let's get gold price!
  agent = Mechanize.new
  gold = agent.get(gold_url)
  html_gold = Nokogiri::HTML(gold.body, 'UTF-8')
  html_gold.css('div.content-blk span#sp-bid').each do |elt|
    @gold_value = elt.text.strip.delete(',').to_f.round(2)
  end

  # Let's get silver price!
  agent_silver = Mechanize.new
  silver = agent_silver.get(silver_url)
  html_silver = Nokogiri::HTML(silver.body, 'UTF-8')
  html_silver.css('div.content-blk span#sp-bid').each do |elt|
    @silver_value = elt.text.strip.delete(',').to_f.round(2)
  end

  # Set currency value from json
  currency_symbol.each do |sym|
    @store.hset(sym, :currency, rates['rates'][sym].to_f.round(2))
    @store.hset(sym, :gold_value, @gold_value)
    @store.hset(sym, :url, sym)
    @store.hset(sym, :silver_value, @silver_value)
    @store.hset(sym, :last_update, @last_update)
  end

  # Local prices for each marking probe of gold in local currency
  usd_rate = probe_arr(@gold_value, mark_gold).to_h
  usd_rate.each do |key, value|
    currency_symbol.each do |sym|
      @store.hset(sym, :"#{key}", (value * rates['rates'][sym].to_f).round(2))
    end
    @store.hset('USD', key, value)
  end

  # Local silver prices for each weight in local currency
  silver_rate_in_usd = probe_arr(@silver_value, mark_silver).to_h
  silver_rate_in_usd.each do |key, value|
    currency_symbol.each do |sym|
      @store.hset(sym, :"silver_#{key}", (value * rates['rates'][sym].to_f).round(2))
    end
  end

  puts 'Done!'
 end