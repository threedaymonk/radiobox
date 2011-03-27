require "open-uri"
require "json"
require "net/http"
require "uri"
require "set"

module Soundcloud
  module UserWhitelist
    def whitelist
      @whitelist ||= Set.new
    end

    def include?(user)
      whitelist.include?(user)
    end

    def add(user)
      whitelist << user
    end

    extend self
  end

  module CommentCleaner
    def clean(comments)
      comments.select{ |c|
        Soundcloud::UserWhitelist.include?(c["user"]["username"])
      }.map{ |c| {
        :id => c["id"],
        :body => body(c["body"]),
        :type => type(c["body"]),
        :timestamp => c["timestamp"]
      }}
    end

    def type(comment)
      case comment
      when /flickr.com/
        :flickr
      when /dbpedia.org/
        :dbpedia
      when /wikipedia.org/
        :wikipedia
      when %r{https?://}
        :link
      else
        :text
      end
    end

    def body(comment)
      if m = comment.match(%r!https?://[^\s'"]+!)
        m[0]
      else
        comment
      end
    end

    extend self
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
