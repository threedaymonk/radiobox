require "open-uri"
require "json"
require "net/http"
require "uri"

module Soundcloud
  class CommentCleaner
    USER_WHITELIST = ["Jelion", "saidfm", "chris-lowis"]

    def self.clean(comments)
      new_comments = []
      comments.map do |c|
        new_comments << {
          :body => c["body"],
          :type => self.type(c["body"])
        } if USER_WHITELIST.include? c["user"]["username"]
      end
      new_comments
    end

    def self.type(comment)
      case comment
      when /flickr.com/
        :flickr
      when /dbpedia.org/
        :dbpedia
      else
        :text
      end
    end
  end

  class API
    ROOT = "http://api.soundcloud.com"

    def initialize(client_id)
      @client_id = client_id
    end

    def track(track_id)
      get("tracks", track_id)
    end

    def clean_comments(track_id)
      CommentCleaner.clean(comments(track_id))
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
