require "rubygems"
require "sinatra"

set :run, false
set :environment, ENV["RACK_ENV"]

require "blip-twitter-api"
run Sinatra.application