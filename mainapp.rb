require 'sinatra/base'
require 'sinatra/content_for'
require 'yaml'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base
  helpers Sinatra::GoldRate
  helpers Sinatra::ContentFor

  before do
    @yaml_store ||= YAML.load_file(File.join('meta.yml'))
    @curr_symbols = {}
    @yaml_store.each_pair { |key, value| @curr_symbols[key] = value[:meta_country].last }
    @today = Time.now
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

  get '/:url' do
    if @yaml_store.key?(params[:url].upcase)
      @price = get_db($redis, params[:url].upcase)
      @metatag = @yaml_store.fetch(params[:url].upcase)
      @current_url = @price.fetch('url')
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
