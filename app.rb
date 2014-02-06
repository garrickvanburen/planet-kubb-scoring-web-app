require 'rubygems'
require 'media_wiki'
require 'bundler/setup'
require 'sinatra'


configure :test do
  disable :raise_errors, :dump_errors, :logging, :show_exceptions
  PROTOCOL          = "http"
  APP_DOMAIN        = "kubbscore"
  TLD               = "dev"
end


configure :development do
  PROTOCOL          = "http"
  APP_DOMAIN        = "kubbscore"
  TLD               = "dev"
end


configure :production do
  PROTOCOL          = "http"
  APP_DOMAIN        = "kubbscore"
  TLD               = "com"
end


configure do

  SESSION_DOMAIN    = "." + APP_DOMAIN + "." + TLD
  APP_URL           = APP_DOMAIN + "." + TLD +  "/"

  Pony.options = {
    :from             => 'garrick@kubbstats.com',
    :reply_to         => 'garrick@kubbstats.com',
    :via              => :smtp,
    :via_options  => {
      :address        => 'smtp.mxes.net',
      :port           => '443',
      :user_name      => 'garrick_garrickvanburen.co',
      :password       => 'e7lKKcsq3kdz',
      :authentication => :login, #:plain , :login, :cram_md5, no auth by default
      :domain         => "kubbstats.com", # the HELO domain provided by the client to the server
      :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
      :enable_starttls_auto => true
    }
  }

  unless :agent.to_s =~ /(Slurp|msnbot|Googlebot)/
    # DO I NEED DOMAIN IN HERE? IF SO...
    #  :domain => SESSION_DOMAIN,
    use Rack::Session::Cookie, :key => 'user',
                               :path => '/',
                               :domain => SESSION_DOMAIN,
                               :expire_after => 60 * 60 * 24 * 365 * 5,
                               :secret => 'ZDcgRYTljlWPD]zSicMmCXaUdaFdQ2sX1ZNkw4'

  end

  mime_type :appcache, "text/cache-manifest"
end


helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def send_to_wiki(params)
    mw = MediaWiki::Gateway.new(params[:url] + '/w/api.php')
    mw.login(params[:user], params[:pass])
    return mw.create(params[:page_title], params[:page_content], :summary => 'hello world')
  end


  def send_notification(opts)
    Pony.mail(
      :to               => opts[:to],
      :subject          => '[' + APP_DOMAIN  + '] ' + opts[:subject],
      :body             => opts[:body],
      :html_body        => opts[:html_body] || opts[:body]
    )
  end
end


before do
  @current_user = session['user'] || nil

end


get '/app.appcache' do
  expires 0, :no_cache, :must_revalidate
  content_type :appcache
  erb :appcache, :layout => false
end


get '/' do
  erb :index
end


post '/' do
  send_to_wiki(params)
  redirect '/'
end

