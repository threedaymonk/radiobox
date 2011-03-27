root = File.expand_path(File.dirname(__FILE__))
lib = File.join(root, "lib")
$:.unshift lib unless $:.include?(lib)

require "sinatra"
require "slim"
require "cache"
require "soundcloud"
require "flickr"
require "http"

cache = Cache.new(`git log | head -n 1 | cut -d' ' -f 2`)
soundcloud = cache.wrap(Soundcloud::API.new(ENV["SOUNDCLOUD_CLIENT_ID"]))
flickr = cache.wrap(Flickr::API.new(ENV["FLICKR_API_KEY"]))
wikipedia = cache.wrap(Wikipedia::API.new())

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
  @comments.unshift(
    :body => @track_info["user"]["username"] + ": " + @track_info["title"],
    :type => "title",
    :timestamp => 0,
    :id => 0
  )
  stream      = soundcloud.auth(@track_info["stream_url"])
  @stream_src = HTTP.head(stream)["Location"]
  slim :track
end

get "/track/:artist/:song" do
  track_id = soundcloud.resolve(params["artist"], params["song"])
  redirect "/track/#{track_id}"
end

get "/flickr/*" do
  flickr.original_image(params[:splat].first)
end

get "/wikipedia/*" do
  wikipedia.comment(params[:splat].first)
end

get "/track-info/:track" do
  track_id = params["track"].to_i
  JSON.dump({
    :track    => soundcloud.track(track_id),
    :comments => soundcloud.comments(track_id)
  })
end
