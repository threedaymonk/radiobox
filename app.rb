root = File.expand_path(File.dirname(__FILE__))
lib = File.join(root, "lib")
$:.unshift lib unless $:.include?(lib)

require "sinatra"
require "slim"
require "cache"
require "soundcloud"
require "http"

soundcloud = Cache.new.wrap(Soundcloud::API.new(ENV["SOUNDCLOUD_CLIENT_ID"]))
ENV["SOUNDCLOUD_USER_WHITELIST"].split(/ /).each do |user|
  Soundcloud::UserWhitelist.add user
end

Slim::Engine.set_default_options :pretty => true

helpers do
end

get "/" do
  slim :index
end

get "/track/:track" do
  @track_id   = params["track"].to_i
  @track_info = soundcloud.track(@track_id)
  @comments   = soundcloud.clean_comments(@track_id)
  slim :track
end

get "/track/:artist/:song" do
  track_id = soundcloud.resolve(params["artist"], params["song"])
  redirect "/track/#{track_id}"
end

get "/stream/:track" do
  track_id = params["track"].to_i
  track    = soundcloud.track(track_id)
  stream   = soundcloud.auth(track["stream_url"])
  redirect HTTP.head(stream)["Location"]
end

get "/track-info/:track" do
  track_id = params["track"].to_i
  JSON.dump({
    :track    => soundcloud.track(track_id),
    :comments => soundcloud.comments(track_id)
  })
end
