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

kzt_url = URI('http://nationalbank.kz/?docid=747&switch=russian')
kgs_url = URI('http://www.nbkr.kg/XML/daily.xml')
gold_url = 'http://www.kitco.com/charts/livegold.html'
mark_gold = [0.375, 0.583, 0.585, 0.750, 0.916, 0.999]
@store = Redis.new(:url => ENV["REDISCLOUD_URL"])

    # Let's get KZT currency rate
    kzt_page = Net::HTTP.get(kzt_url)
    html_kzt = Nokogiri::HTML(kzt_page)
    html_kzt.css('.gen7').select do |elt|
      if elt.text.include?("USD")
      @currency_kzt = elt.next_element.text.strip.to_f
      @store.hset("KZT", :currency_kzt, @currency_kzt) unless @currency_kzt.nil?
      end
        
    end
    # Let's get KGS currency rate
    kgs_page = Net::HTTP.get(kgs_url)
    html_kgs = Nokogiri::XML(kgs_page)
      html_kgs.css('Currency').select do |elt|
      if elt['ISOCode'] == 'USD'
        @currency_kgs = elt.css('Value').text.sub(',', '.').to_f.round(2)
        @store.hset("KGS", :currency_kgs, @currency_kgs) 
      end
    end
  # Let's get gold price!
   agent = Mechanize.new
    gold = agent.get(gold_url)
    html_gold = Nokogiri::HTML(gold.body, 'UTF-8')

      html_gold.css('div.content-blk span#sp-bid').each do |elt|
        @gold_value = elt.text.strip.delete(',').to_f.round(2)
        @store.hset("KZT", :gold_value, @gold_value)
        @store.hset("KGS", :gold_value, @gold_value)   
      end

   # USD prices per each marking probe for gold
   usd_rate = probe_arr(@gold_value, mark_gold).to_h
     usd_rate.each do |key, value|
     @store.hset("KGS", :"#{key}", (value * @currency_kgs.to_f).round(2))
     @store.hset("KZT", :"#{key}", (value * @currency_kzt.to_f).round(2))
     @store.hset("USD", key, value)
     end

puts 'Done!'
end
