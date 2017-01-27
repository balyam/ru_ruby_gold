require 'sinatra/base'

class GoldRate < Sinatra::Base

require 'net/http'
require 'nokogiri'
require 'mechanize'
require 'json'
require 'yaml/store'


currency_url = URI('http://nationalbank.kz/?docid=747&switch=russian')
gold_url = 'http://www.kitco.com/charts/livegold.html'
showings = []
mark_gold = [0.375, 0.583, 0.585, 0.750, 0.916]
store = YAML::Store.new("db.yml")

# puts "Let's start currency"
  currency_page = Net::HTTP.get(currency_url)
    html_currency = Nokogiri::HTML(currency_page)  

html_currency.css('.gen7').select do |elt|

   if elt.text.include? ("USD")
    @currency_value = elt.next_element.text.strip.to_f  
    showings.push(currency_value: @currency_value) unless  @currency_value.nil?
   end
    
end

#puts "Let's start gold price!" 
  agent = Mechanize.new 
    gold = agent.get(gold_url)
      html_gold = Nokogiri::HTML(gold.body, 'UTF-8')

  html_gold.css('div.content-blk span#sp-bid').each do |elt|

     @gold_value = elt.text.strip.delete(",").to_f
     
     showings.push(gold_value: @gold_value)
    
  end
#Prices of each marking probe for gold
   mark_gold.each do |probe|
    showings.push("#{probe}": ((@gold_value/31.103) * @currency_value * probe).to_i)
  end

#Store values in YAML database db.store
  store.transaction do
    store["rate"] = showings
  end
  puts showings
  
puts JSON.pretty_generate(showings)

end


  