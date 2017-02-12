require 'rubygems'
require 'bundler'

Bundler.require

configure do 
  require 'redis'
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

require './mainapp'
run MainApp