require 'sinatra/base'
require_relative './helpers/goldrate'

class MainApp < Sinatra::Base
  helpers Sinatra::GoldRate

  before do
    @curr_symbols ||= %w(KZT KGS RUB BYN AZN UZS UAH)
  end

  get '/' do
    @price = get_db($redis, 'KZT')
    erb :index
  end

  get '/:url' do
    @price = get_db($redis, params[:url].upcase)
    erb :rub
  end
end
