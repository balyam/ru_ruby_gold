require 'sinatra/base'

module GetRate

require 'net/http'
require 'nokogiri'
require 'mechanize'
require 'json'
require 'yaml/store'


kzt_url = URI('http://nationalbank.kz/?docid=747&switch=russian')
kgs_url = URI('http://www.nbkr.kg/XML/daily.xml')
gold_url = 'http://www.kitco.com/charts/livegold.html'
mark_gold = [0.375, 0.583, 0.585, 0.750, 0.916, 0.999]
showings = {}
@store = YAML::Store.new("db.yml")


# puts "Let's get KZT currency rate"
  kzt_page = Net::HTTP.get(kzt_url)
    html_kzt = Nokogiri::HTML(kzt_page)  

    html_kzt.css('.gen7').select do |elt|
       if elt.text.include? ("USD")
        @currency_kzt = elt.next_element.text.strip.to_f  
        showings[:currency_kzt] = @currency_kzt unless  @currency_kzt.nil?
       end
        
    end
=begin
#puts "Let's get KGS currency rate"
  kgs_page = Net::HTTP.get(kgs_url)
    html_kgs = Nokogiri::XML(kgs_page)
    html_kgs.css("Currency").select do |elt|
        puts elt
          
      showings[:currency_kgs] = elt.css('Value').text.strip
        
    end
=end

#puts "Let's get gold price!" 
  agent = Mechanize.new 
    gold = agent.get(gold_url)
      html_gold = Nokogiri::HTML(gold.body, 'UTF-8')

      html_gold.css('div.content-blk span#sp-bid').each do |elt|
        @gold_value = elt.text.strip.delete(",").to_f
        showings[:gold_value] =  @gold_value    
      end

#Prices per gramm of each marking probe for gold
   mark_gold.each do |probe|
    showings[:"#{probe}"] = ((@gold_value/31.103) * @currency_kzt * probe).to_i
  end

#Store values in YAML database db.store
  @store.transaction do
    @store["rate"] = showings
  end

puts "Done!"

end




  