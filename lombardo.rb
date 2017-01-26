puts "Let's start!"
require 'net/http'
require 'nokogiri'
require 'json'

url = URI('http://nationalbank.kz/?docid=747&switch=russian')
html = Net::HTTP.get(url)

doc = Nokogiri::HTML(html)
showings = []
=begin
doc.css('.showing').each do |showing|
  showing_id = showing['id'].split('_').last.to_i
  tags = showing.css('.tags a').map { |tag| tag.text.strip }
  title_el = showing.at_css('h1 a')
  title_el.children.each { |c| c.remove if c.name == 'span' }
  title = title_el.text.strip
  dates = showing.at_css('.start_and_pricing').inner_html.strip
  dates = dates.split('<br>').map(&:strip).map { |d| DateTime.parse(d) }
  description = showing.at_css('.copy').text.gsub('[more...]', '').strip
  showings.push(
    id: showing_id,
    title: title,
    tags: tags,
    dates: dates,
    description: description
  )
end
=end
doc.css('.gen7').each do |gen|

  td_value = gen.next_element.text.strip if gen.text.include? ("USD")

  showings.push(td_value: td_value.to_f) unless  td_value.nil?
    
end
  
puts JSON.pretty_generate(showings)