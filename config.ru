require 'rubygems'
require 'bundler'
Bundler.require

if ENV['RACK_ENV'] == 'production'
	require '/srv/www/pk-scoresheet/current/app.rb'
else
	require '/Users/garrick/Documents/apps/pk-scoresheet/app.rb'
end


Sinatra::Application.set(
  :run => false,
  :environment => ENV['RACK_ENV']
)

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)


run Sinatra::Application

