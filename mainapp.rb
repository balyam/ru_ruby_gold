require 'sinatra/base'
require 'sinatra/content_for'
require 'yaml'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base
  helpers Sinatra::GoldRate
  helpers Sinatra::ContentFor

  before do
    @top_menu_symbols ||= %w[KZT KGS AZN UZS]
    @yaml_store ||= YAML.load_file(File.join('meta.yml'))    
    @today = Time.now
    @allcurr = %w[KZT KGS RUB BYN AZN UZS UAH AMD GEL MDL TJS TMT]

    @curr_symbols = {}

    @yaml_store.each_pair do |key, value|
      @curr_symbols[key] = value[:meta_country].last
    end
  end

  get '/' do
    @price = get_db($redis, 'KZT')
    @metatag = @yaml_store.fetch('KZT')
    @current_url = @price.fetch('url')
    erb :index
  end

  get '/disclaimer' do
    erb :disclaimer
  end

  get '/allcurr' do
    erb :allcurr
  end

  get '/contact' do
    erb :contact
  end

  get '/:url' do
    @url = params[:url].upcase
    if url_valid?(@url, @yaml_store)
      @price = get_db($redis, @url)
      @metatag = @yaml_store.fetch(@url)
      erb :rub
    else
      halt 404
    end
  end

  not_found do
    erb :'404'
  end

  error do
    'Sorry there was a nasty error'
  end
end
