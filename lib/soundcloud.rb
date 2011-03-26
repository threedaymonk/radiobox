require "open-uri"
require "json"

module Soundcloud
  class API
    ROOT = "http://api.soundcloud.com"

    def initialize(client_id)
      @client_id = client_id
    end

    def track(track_id)
      get("tracks", track_id)
    end

    def comments(track_id)
      get("tracks", track_id, "comments")
    end

    def url(*u)
      "#{ROOT}/#{u.join("/")}.json?consumer_key=#{@client_id}"
    end

    def get(*u)
      open url(*u) do |f|
        JSON.parse(f.read)
      end
    end
  end
end
