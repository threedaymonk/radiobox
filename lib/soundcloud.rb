require "open-uri"
require "json"
require "net/http"
require "uri"

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
      "#{ROOT}/#{u.join("/")}.json"
    end

    def auth(url)
      "#{url}?consumer_key=#{@client_id}"
    end

    def resolve(user, track)
      url = "#{ROOT}/resolve?url=http://soundcloud.com/#{user}/#{track}&consumer_key=#{@client_id}"
      begin
        response = Net::HTTP.get_response(URI.parse(url))
        location = response.header['location']
        track_id = URI.parse(location).path.split('/').last
      rescue
        return nil
      end
      track_id
    end

    def get(*u)
      open auth(url(*u)) do |f|
        JSON.parse(f.read)
      end
    end
  end
end
