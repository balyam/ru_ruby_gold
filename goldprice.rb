puts "Let's start gold price!"
require 'net/http'
require 'nokogiri'
require 'mechanize'
require 'json'


url = 'http://www.kitco.com/charts/livegold.html'
agent = Mechanize.new

gold = agent.get(url)
html_gold = Nokogiri::HTML(doc.body, 'UTF-8')

showings = []

  html_gold.css('div.content-blk span#sp-bid').each do |gen|

     td_value = gen.text.strip.delete ","

     showings.push(td_value: td_value.to_f)
    
  end

puts html_gold 
puts JSON.pretty_generate(showings)