require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "BlipTwitt", "Class" do
  it "defines status method" do
    BlipTwitt.should respond_to(:status)
  end
  
  it "defines user method" do
    BlipTwitt.should respond_to(:user)
  end
end

describe "BlipTwitt", "Class method user" do
  it "renders user data when no avatar, background or current_status are given" do
    user = BlipTwitt.user(Yajl::Parser.parse(%q{{
      "id": 2,
      "login": "wiesiek",
      "background_path": "/users/sztywny/background",
      "avatar_path": "/users/sztywny/avatar",
      "current_status_path": "/statuses/12345"
    }}))
    
    user["id"].should == 2
    user["name"].should == "wiesiek"
    user["profile_background_image_url"].should == ""
    user["profile_image_url"].should == ""
    user["screen_name"].should == "wiesiek"
    user["url"].should == "http://wiesiek.blip.pl/"
    user["status"]["created_at"].should == ""
    user["status"]["id"].should == 0
    user["status"]["source"].should == ""
    user["status"]["text"].should == ""
  end
  
  it "renders user data when avatar is given" do
    user = BlipTwitt.user(Yajl::Parser.parse(%q{{
      "avatar": {
        "id": 699087, 
        "url": "http://blip.pl/user_generated/avatars/699087.jpg", 
        "url_120": "/user_generated/avatars/699087_large.jpg", 
        "url_15": "/user_generated/avatars/699087_femto.jpg", 
        "url_30": "/user_generated/avatars/699087_nano.jpg", 
        "url_50": "/user_generated/avatars/699087_pico.jpg", 
        "url_90": "/user_generated/avatars/699087_standard.jpg"
      }, 
      "background_path": "/users/filiptepper/background", 
      "current_status_path": "/s/28328513", 
      "id": 154, 
      "login": "filiptepper", 
      "sex": "m"
    }}))
    
    user["id"].should == 154
    user["name"].should == "filiptepper"
    user["profile_background_image_url"].should == ""
    user["profile_image_url"].should == "http://blip.pl/user_generated/avatars/699087_pico.jpg"
    user["screen_name"].should == "filiptepper"
    user["url"].should == "http://filiptepper.blip.pl/"
    user["status"]["created_at"].should == ""
    user["status"]["id"].should == 0
    user["status"]["source"].should == ""
    user["status"]["text"].should == ""
  end
  
  it "renders user data when avatar and background are given" do
    user = BlipTwitt.user(Yajl::Parser.parse(%q{{
      "avatar": {
        "id": 699087, 
        "url": "http://blip.pl/user_generated/avatars/699087.jpg", 
        "url_120": "/user_generated/avatars/699087_large.jpg", 
        "url_15": "/user_generated/avatars/699087_femto.jpg", 
        "url_30": "/user_generated/avatars/699087_nano.jpg", 
        "url_50": "/user_generated/avatars/699087_pico.jpg", 
        "url_90": "/user_generated/avatars/699087_standard.jpg"
      }, 
      "background": {
        "id": 693043, 
        "url": "http://blip.pl/user_generated/backgrounds/693043.jpg"
      }, 
      "current_status_path": "/s/28328513", 
      "id": 154, 
      "login": "filiptepper", 
      "sex": "m"
    }}))
    
    user["id"].should == 154
    user["name"].should == "filiptepper"
    user["profile_background_image_url"].should == "http://blip.pl/user_generated/backgrounds/693043.jpg"
    user["profile_image_url"].should == "http://blip.pl/user_generated/avatars/699087_pico.jpg"
    user["screen_name"].should == "filiptepper"
    user["url"].should == "http://filiptepper.blip.pl/"
    user["status"]["created_at"].should == ""
    user["status"]["id"].should == 0
    user["status"]["source"].should == ""
    user["status"]["text"].should == ""
  end
  
  it "renders user data when avatar, background and current_status are given" do
    user = BlipTwitt.user(Yajl::Parser.parse(%q{{
      "avatar": {
        "id": 699087, 
        "url": "http://blip.pl/user_generated/avatars/699087.jpg", 
        "url_120": "/user_generated/avatars/699087_large.jpg", 
        "url_15": "/user_generated/avatars/699087_femto.jpg", 
        "url_30": "/user_generated/avatars/699087_nano.jpg", 
        "url_50": "/user_generated/avatars/699087_pico.jpg", 
        "url_90": "/user_generated/avatars/699087_standard.jpg"
      }, 
      "background": {
        "id": 693043, 
        "url": "http://blip.pl/user_generated/backgrounds/693043.jpg"
      }, 
      "current_status": {
        "body": "#tvn24 o napisie nad bram\u0105: \"no przecie\u017c chyba nie b\u0119dzie klejona, prawda?\".", 
        "created_at": "2009-12-22 14:05:01", 
        "id": 28328513, 
        "transport": {
          "id": 6, 
          "name": "www"
        }, 
        "type": "Status"
      }, 
      "id": 154, 
      "login": "filiptepper", 
      "sex": "m"
    }}))
    
    user["id"].should == 154
    user["name"].should == "filiptepper"
    user["profile_background_image_url"].should == "http://blip.pl/user_generated/backgrounds/693043.jpg"
    user["profile_image_url"].should == "http://blip.pl/user_generated/avatars/699087_pico.jpg"
    user["screen_name"].should == "filiptepper"
    user["url"].should == "http://filiptepper.blip.pl/"
    user["status"]["created_at"].should == "Tue Dec 22 14:05:01 +0100 2009"
    user["status"]["id"].should == 28328513
    user["status"]["source"].should == "www"
    user["status"]["text"].should == "#tvn24 o napisie nad bramą: \"no przecież chyba nie będzie klejona, prawda?\"."
  end
end

describe "BlipTwitt", "Class method status" do
  it "renders status data when no user, avatar or recipient are given" do
    status = BlipTwitt.status(Yajl::Parser.parse(%q{{
      "body": "b\u0119dzie publiczna egzekucja z\u0142odziei napisu z o\u015bwi\u0119cimia? eseik w wyborczej o banalno\u015bci zua?", 
      "created_at": "2009-12-22 15:09:02", 
      "id": 28342024, 
      "transport": {
          "id": 3, 
          "name": "jabber"
      }, 
      "type": "Status", 
      "user_path": "/users/reuptake"
    }}))
    
    status["id"].should == 28342024
    status["created_at"].should == "Tue Dec 22 15:09:02 +0100 2009"
    status["source"].should == "jabber"
    status["text"].should == "będzie publiczna egzekucja złodziei napisu z oświęcimia? eseik w wyborczej o banalności zua?"
  end

  it "renders status data when user is given" do
    status = BlipTwitt.status(Yajl::Parser.parse(%q{{
      "body": "b\u0119dzie publiczna egzekucja z\u0142odziei napisu z o\u015bwi\u0119cimia? eseik w wyborczej o banalno\u015bci zua?", 
      "created_at": "2009-12-22 15:09:02", 
      "id": 28342024, 
      "transport": {
        "id": 3, 
        "name": "jabber"
      }, 
      "type": "Status", 
      "user": {
        "avatar_path": "/users/reuptake/avatar", 
        "id": 3, 
        "location": "Warszawa", 
        "login": "reuptake", 
        "sex": "m"
      }
    }}))
    
    status["id"].should == 28342024
    status["created_at"].should == "Tue Dec 22 15:09:02 +0100 2009"
    status["source"].should == "jabber"
    status["text"].should == "będzie publiczna egzekucja złodziei napisu z oświęcimia? eseik w wyborczej o banalności zua?"
    status["user"]["id"].should == 3
    status["user"]["name"].should == "reuptake"
    status["user"]["screen_name"].should == "reuptake"
    status["user"]["url"].should == "http://reuptake.blip.pl/"
  end
  
  it "renders status data when user and avatar given" do
    status = BlipTwitt.status(Yajl::Parser.parse(%q{{
      "body": "b\u0119dzie publiczna egzekucja z\u0142odziei napisu z o\u015bwi\u0119cimia? eseik w wyborczej o banalno\u015bci zua?", 
      "created_at": "2009-12-22 15:09:02", 
      "id": 28342024, 
      "transport": {
        "id": 3, 
        "name": "jabber"
      }, 
      "type": "Status", 
      "user": {
        "avatar": {
          "id": 682467, 
          "url": "http://blip.pl/user_generated/avatars/682467.jpg", 
          "url_120": "/user_generated/avatars/682467_large.jpg", 
          "url_15": "/user_generated/avatars/682467_femto.jpg", 
          "url_30": "/user_generated/avatars/682467_nano.jpg", 
          "url_50": "/user_generated/avatars/682467_pico.jpg", 
          "url_90": "/user_generated/avatars/682467_standard.jpg"
        }, 
        "id": 3, 
        "location": "Warszawa", 
        "login": "reuptake", 
        "sex": "m"
      }
    }}))
    
    status["id"].should == 28342024
    status["created_at"].should == "Tue Dec 22 15:09:02 +0100 2009"
    status["source"].should == "jabber"
    status["text"].should == "będzie publiczna egzekucja złodziei napisu z oświęcimia? eseik w wyborczej o banalności zua?"
    status["user"]["id"].should == 3
    status["user"]["name"].should == "reuptake"
    status["user"]["screen_name"].should == "reuptake"
    status["user"]["url"].should == "http://reuptake.blip.pl/"
    status["user"]["profile_image_url"].should == "http://blip.pl/user_generated/avatars/682467_pico.jpg"
  end

  it "renders directed message data when user, avatar and recipient given" do
    status = BlipTwitt.status(Yajl::Parser.parse(%q{{
      "body": "kurde.", 
      "created_at": "2009-12-22 14:44:55", 
      "id": 28337448, 
      "recipient": {
          "avatar_path": "/users/reuptake/avatar", 
          "current_status_path": "/s/28342024", 
          "id": 3, 
          "location": "Warszawa", 
          "login": "reuptake", 
          "sex": "m"
      }, 
      "transport": {
          "id": 6, 
          "name": "www"
      }, 
      "type": "DirectedMessage", 
      "user": {
          "avatar": {
              "id": 225691, 
              "url": "http://blip.pl/user_generated/avatars/225691.jpg", 
              "url_120": "/user_generated/avatars/225691_large.jpg", 
              "url_15": "/user_generated/avatars/225691_femto.jpg", 
              "url_30": "/user_generated/avatars/225691_nano.jpg", 
              "url_50": "/user_generated/avatars/225691_pico.jpg", 
              "url_90": "/user_generated/avatars/225691_standard.jpg"
          }, 
          "current_status_path": "/s/28336973", 
          "id": 39287, 
          "location": "Warszawa, Krak\u00f3w, Polska", 
          "login": "adtaily", 
          "sex": ""
      }
    }}))
    
    status["id"].should == 28337448
    status["created_at"].should == "Tue Dec 22 14:44:55 +0100 2009"
    status["source"].should == "www"
    status["text"].should == "@reuptake kurde."
    status["user"]["id"].should == 39287
    status["user"]["name"].should == "adtaily"
    status["user"]["screen_name"].should == "adtaily"
    status["user"]["url"].should == "http://adtaily.blip.pl/"
    status["user"]["profile_image_url"].should == "http://blip.pl/user_generated/avatars/225691_pico.jpg"
  end
  
  it "renders private message data when user, avatar and recipient given" do
    status = BlipTwitt.status(Yajl::Parser.parse(%q{{
      "body": "Nic Ci sie nie stalo? :-(", 
      "created_at": "2009-12-23 08:33:47", 
      "id": 28514277, 
      "recipient": {
          "avatar_path": "/users/marynka/avatar", 
          "current_status_path": "/s/25604811", 
          "id": 148488, 
          "location": "Warszawa, Polska", 
          "login": "marynka", 
          "sex": "f"
      }, 
      "transport": {
          "id": 7, 
          "name": "api"
      }, 
      "type": "PrivateMessage", 
      "user": {
          "avatar": {
              "id": 699087, 
              "url": "http://blip.pl/user_generated/avatars/699087.jpg", 
              "url_120": "/user_generated/avatars/699087_large.jpg", 
              "url_15": "/user_generated/avatars/699087_femto.jpg", 
              "url_30": "/user_generated/avatars/699087_nano.jpg", 
              "url_50": "/user_generated/avatars/699087_pico.jpg", 
              "url_90": "/user_generated/avatars/699087_standard.jpg"
          }, 
          "background_path": "/users/filiptepper/background", 
          "current_status_path": "/s/28510149", 
          "id": 154, 
          "location": "Bemowo, Warszawa, Polska", 
          "login": "filiptepper", 
          "sex": "m"
      }
    }}))
    
    status["id"].should == 28514277
    status["created_at"].should == "Wed Dec 23 08:33:47 +0100 2009"
    status["source"].should == "api"
    status["text"].should == "@@marynka Nic Ci sie nie stalo? :-("
    status["user"]["id"].should == 154
    status["user"]["name"].should == "filiptepper"
    status["user"]["screen_name"].should == "filiptepper"
    status["user"]["url"].should == "http://filiptepper.blip.pl/"
    status["user"]["profile_image_url"].should == "http://blip.pl/user_generated/avatars/699087_pico.jpg"
  end
  
  it "renders notice data when user, avatar and recipient given" do
    status = BlipTwitt.status(Yajl::Parser.parse(%q{
      {"user": {"current_status_path": "/s/28603565", "id": 35148, "sex": "m", "avatar": {"url_50":"/user_generated/avatars/218458_pico.jpg", "url_120":"/user_generated/avatars/218458_large.jpg", "url_30":"/user_generated/avatars/218458_nano.jpg", "url":"http://blip.pl/user_generated/avatars/218458.jpg", "id":218458, "url_90":"/user_generated/avatars/218458_standard.jpg", "url_15":"/user_generated/avatars/218458_femto.jpg"}, "login":"opi", "location":"Lodz, Polska"}, "body":"^opi mówi o Tobie: http://blip.pl/s/28603565", "type":"Notice", "id":28603567, "created_at":"2009-12-23 16:18:24"}
    }))
    
    status["id"].should == 28603567
    status["created_at"].should == "Wed Dec 23 16:18:24 +0100 2009"
    status["text"].should == "^opi mówi o Tobie: http://blip.pl/s/28603565"
    status["user"]["id"].should == 35148
    status["user"]["name"].should == "opi"
    status["user"]["screen_name"].should == "opi"
    status["user"]["url"].should == "http://opi.blip.pl/"
    status["user"]["profile_image_url"].should == "http://blip.pl/user_generated/avatars/218458_pico.jpg"
  end
end