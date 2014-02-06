require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'media_wiki'


configure :development do
end

configure :production do
end


helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  expires 0, :public, :must_revalidate
  
  
  def push_to_mediawiki(entry={})
   mw = MediaWiki::Gateway.new(entry[:url] + '/w/api.php')
   mw.login(entry[:lgname], entry[:lgpass])
   mw.create(entry[:title], entry[:content], :summary => entry[:comment]) unless mw.get(entry[:title])
  end
  
end


get '/manifest.appcache' do   
  expires 0, :no_cache, :must_revalidate
  content_type :appcache      
  erb :appcache, :layout => false
end


get '/' do
  erb :index
end

post '/' do
  push_to_mediawiki(params)
end


