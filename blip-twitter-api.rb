require "rubygems"
require "sinatra"
require "httparty"
require "bliptwitt"
require "yajl"
require "yajl/json_gem"

set :port, 80

class Blip
  include HTTParty
  base_uri "api.blip.pl"
  
  def initialize(username, password)
    @auth = { :username => username, :password => password }
    @headers = {
      "User-Agent" => "Blip-Twitter Conduit",
      "X-Blip-API" => "0.02",
      "Accept" => "application/json"
    }
  end
  
  def fetch(url)
    options = { :basic_auth => @auth, :headers => @headers }
    self.class.get(url, options)
  end
  
  def write(url, body)
    options = { :basic_auth => @auth, :headers => @headers, :body => body}
    self.class.post(url, options)
  end
end

before do
  @basic_auth = Rack::Auth::Basic::Request.new(request.env)
  @blip = Blip.new(@basic_auth.credentials[0], @basic_auth.credentials[1]) if @basic_auth.provided? && @basic_auth.basic? && @basic_auth.credentials
end

post "/statuses/update.json" do
  status = params["status"]
  status = status.gsub(/^@@/, ">>").gsub(/^@/, ">")
  
  posted = @blip.write("/updates", { :update => { :body => status } } )
  
  if status =~ /^>>/
    message = @blip.fetch("/private_messages/#{posted["id"]}?include=user,user[avatar],user[background],recipient")
  else
    message = @blip.fetch("/updates/#{posted["id"]}?include=user,user[avatar],user[background],recipient")
  end
  BlipTwitt.status(message).to_json
end

post "/direct_messages/new.json" do
  status = ">>#{params["user"]} #{params["text"]}"
  
  posted = @blip.write("/updates", { :update => { :body => status } } )
  
  message = @blip.fetch("/private_messages/#{posted["id"]}?include=user,user[avatar],user[background],recipient")
  BlipTwitt.status(message).to_json
end

get "/statuses/replies.json" do
  directed_messages = @blip.fetch("/directed_messages?include=user,user[avatar],user[background],recipient")
  
  timeline = []
  
  directed_messages.each do |message|
    timeline << BlipTwitt.status(message)
  end
  
  timeline.to_json
end

get "/direct_messages.json" do
  private_messages = @blip.fetch("/private_messages?include=user,user[avatar],user[background],recipient")
  
  timeline = []
  
  private_messages.each do |message|
    timeline << BlipTwitt.status(message)
  end
  
  timeline.to_json
end

get "/favorites.json" do
  "[]"
end

get %r{/statuses/(home|friends)_timeline.json} do
  if params[:since_id]
    dashboard = @blip.fetch("/dashboard/since/#{params[:since_id]}?include=user,user[avatar],user[background],recipient")
  else
    dashboard = @blip.fetch("/dashboard?include=user,user[avatar],user[background],recipient")
  end
  
  p dashboard
  
  timeline = []
   
  dashboard.each do |message|
    timeline << BlipTwitt.status(message)
  end
   
  timeline.to_json
end

get "/account/rate_limit_status.json" do
  time = Time.now
  
  rate = {
    "remaining_hits" => 999,
    "hourly_limit" => 999,
    "reset_time" => time.utc,
    "reset_time_in_seconds" => time.strftime("%y%m%d%H%M%S")
  }
  
  rate.to_json
end

get "/account/verify_credentials.json" do
  BlipTwitt.user(@blip.fetch("/profile?include=background,avatar,current_status")).to_json
end

get "/users/show/:login.json" do
  BlipTwitt.user(@blip.fetch("/users/#{params[:login]}?include=background,avatar,current_status")).to_json
end

get "/statuses/show/:id.json" do
  BlipTwitt.status(@blip.fetch("/updates/#{params[:id]}?include=user,user[avatar],recipient")).to_json
end