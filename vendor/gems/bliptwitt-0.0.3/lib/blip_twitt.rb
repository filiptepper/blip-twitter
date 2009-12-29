require "rubygems"
require "time"
require "yajl"

module BlipTwitt
  STATUS = {
    "created_at" => "",
    "id" => 0,
    "source" => "",
    "text" => "",

    "favorited" => false,
    "geo" => nil,
    "in_reply_to_user_id" => nil,
    "in_reply_to_status_id" => nil,
    "in_reply_to_screen_name"=> nil,
    "truncated" => false
  }
  
  USER = { 
    "id" => 0,
    "name" => "",
    "profile_background_image_url" => "",
    "profile_image_url" => "",
    "screen_name" => "",
    "url" => "",
    
    "created_at" => "Tue May 12 08:00:00 +0000 1982",
    "description" => "",
    "favourites_count" => 0,
    "followers_count" => 0,
    "following" => false,
    "friends_count" => 0,
    "geo_enabled" => false,
    "location" => "",
    "notifications" => false,
    "profile_background_color" => "",
    "profile_background_tile" => false,
    "profile_link_color" => "",
    "profile_sidebar_border_color" => "",
    "profile_sidebar_fill_color" => "",
    "profile_text_color" => "",
    "protected" => false,
    "statuses_count" => 0,
    "time_zone" => "Warsaw",
    "utc_offset" => 3600,
    "verified" => false
  }
  
  class << self
    
    def status(blip, sub = false)
      twitter = STATUS.dup
      
      twitter["id"] = blip["id"]
      twitter["created_at"] = format_date blip["created_at"]
      twitter["source"] = blip["transport"]["name"] unless blip["transport"].nil?
      
      case blip["type"]
      when "DirectedMessage"
        twitter["text"] = "@#{blip["recipient"]["login"]} #{blip["body"]}"
      when "PrivateMessage"
        twitter["text"] = "@@#{blip["recipient"]["login"]} #{blip["body"]}"
      else
        twitter["text"] = blip["body"]
      end
      
      unless sub
        twitter["user"] = USER.dup
        
        unless blip["user"].nil?
          twitter["user"] = self.user blip["user"], true
        end
      end
      
      twitter
    end
    
    def user(blip, sub = false)
      twitter = USER.dup
      
      twitter["id"] = blip["id"]
      twitter["name"] = blip["login"]
      twitter["screen_name"] = blip["login"]
      twitter["url"] = "http://#{blip["login"]}.blip.pl/"
      twitter["profile_image_url"] = "http://blip.pl#{blip["avatar"]["url_50"]}" unless blip["avatar"].nil?
      twitter["profile_background_image_url"] = blip["background"]["url"] unless blip["background"].nil?
      
      unless sub
        twitter["status"] = STATUS.dup
      
        unless blip["current_status"].nil?
          twitter["status"] = self.status blip["current_status"], true
        end
      end
      
      twitter
    end
    
    
    private
    
    
    def format_date(string)
      Time.parse(string).to_s
    end
  end
  
end