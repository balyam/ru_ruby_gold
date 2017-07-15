require 'sinatra/base'
require 'sinatra/content_for'
require 'yaml'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base
  helpers Sinatra::GoldRate
  helpers Sinatra::ContentFor

  before do
    @curr_symbols ||= %w(KZT KGS RUB BYN AZN UZS UAH)
    @yaml_store ||= YAML.load_file(File.join('meta.yml'))
  end

  get '/' do
    @price = get_db($redis, 'KZT')
    @metatag = @yaml_store.fetch('KZT')
    erb :index
  end

  get '/:url' do
    @price = get_db($redis, params[:url].upcase)
    @metatag = @yaml_store.fetch(params[:url].upcase)
    erb :rub    
  end
end
