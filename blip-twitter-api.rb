require "rubygems"
require "sinatra"
require "httparty"
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

helpers do
  def update(message)
    {
       "geo" => nil,
       "source" => "web",
       "truncated" => false,
       "favorited" => false, 
       "user" => 
       {
         "profile_background_image_url" => "",
         "description" => "",
         "verified" => false,
         "profile_link_color" => "",
         "profile_background_tile" => false,
         "profile_background_color" => "",
         "following" => false,
         "profile_sidebar_fill_color" => "",
         "followers_count" => 0,
         "statuses_count" => 0,
         "time_zone" => "Warsaw",
         "profile_sidebar_border_color" => "",
         "protected" => false,
         "url" => "",
         "friends_count" => 0,
         "profile_image_url" => "http://blip.pl#{message["user"]["avatar"]["url_30"]}",
         "location" => "",
         "name" => "#{message["user"]["login"]}", 
         "id" => message["user"]["id"],
         "geo_enabled" => false,
         "notifications"=> false,
         "utc_offset" => 3600,
         "favourites_count" => 13,
         "created_at" => "#{Time.parse(message["created_at"]).utc}",
         "profile_text_color" => "",
         "screen_name" => "#{message["user"]["login"]}"
        },
        "in_reply_to_user_id" => nil,
        "in_reply_to_status_id" => nil,
        "in_reply_to_screen_name"=> nil,
        "id" => message["id"],
        "text" => message["recipient"].nil? ? "#{message["body"]}" : "@#{message["recipient"]["login"]} #{message["body"]}",
        "created_at" => "#{Time.parse(message["created_at"]).utc}"
      }
  end
end

post "/statuses/update.json" do
  posted = @blip.write("/updates", { :update => { :body => params["status"] } } )
  message = @blip.fetch("/updates/#{posted["id"]}?include=user,user[avatar],user[background],recipient")
  update(message).to_json
end

get "/statuses/replies.json" do
  directed_messages = @blip.fetch("/directed_messages?include=user,user[avatar],user[background],recipient")
  
  timeline = []
  
  directed_messages.each do |message|
    timeline << update(message)
  end
  
  timeline.to_json
end

get "/direct_messages.json" do
  private_messages = @blip.fetch("/private_messages?include=user,user[avatar],user[background],recipient")
  
  timeline = []
  
  private_messages.each do |message|
    timeline << update(message)
  end
  
  timeline.to_json
end

get "/favorites.json" do
  "[]"
end

get "/statuses/home_timeline.json" do
   dashboard = @blip.fetch("/dashboard?include=user,user[avatar],user[background],recipient")
   
   timeline = []
   
   dashboard.each do |message|
     timeline << update(message)
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
  profile = @blip.fetch("/profile?include=background,avatar,current_status")
  json = %Q{
    {
      "statuses_count": 0,
      "profile_background_image_url": "#{profile["background"]["url"]}",
      "description": "",
      "friends_count":0,
      "profile_link_color": "",
      "status":
      {
        "source": "#{profile["current_status"]["transport"]["name"]}",
        "truncated":false,
        "favorited":false,
        "in_reply_to_user_id":0,
        "in_reply_to_status_id":0,
        "in_reply_to_screen_name":0,
        "id": #{profile["current_status"]["id"]},
        "text":"#{profile["current_status"]["body"]}",
        "created_at":"#{Time.parse(profile["current_status"]["created_at"]).utc}"
      },
      "profile_background_tile":false,
      "notifications":false,
      "favourites_count":0,
      "profile_background_color":"",
      "following":false,
      "verified":false,
      "profile_sidebar_fill_color":"",
      "time_zone":"Warsaw",
      "profile_sidebar_border_color":"",
      "protected":false,
      "url":"",
      "profile_image_url": "http://blip.pl#{profile["avatar"]["url_30"]}",
      "location":"",
      "name":"#{profile["login"]}",
      "id":#{profile["id"]},
      "geo_enabled":false,
      "utc_offset":3600,
      "created_at": "Tue Mar 27 18:41:23 +0000 2007",
      "profile_text_color":"",
      "followers_count": 0,
      "screen_name":"#{profile["login"]}"
    }
  }

  json
end