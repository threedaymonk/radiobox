root = File.expand_path(File.dirname(__FILE__))
lib = File.join(root, "lib")
$:.unshift lib unless $:.include?(lib)

require "sinatra"
require "slim"
require "cache"
require "soundcloud"

soundcloud = Cache.new.wrap(Soundcloud::API.new(ENV["SOUNDCLOUD_CLIENT_ID"]))

Slim::Engine.set_default_options :pretty => true

helpers do
end

get "/" do
  slim :index
end

get "/track-info/:track" do
  track = params["track"].to_i
  JSON.dump({
    :track => soundcloud.track(track),
    :comments => soundcloud.comments(track)
  })
end
