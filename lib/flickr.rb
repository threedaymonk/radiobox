require "rest_client"
require "nokogiri"
require "cgi"

module Flickr
  class API
    BASE = "http://api.flickr.com/services/rest/"

    def initialize(api_key)
      @api_key = api_key
    end

    def original_image(url)
      res = RestClient.get(BASE + query_string(
        :method => "flickr.photos.getSizes",
        :api_key => @api_key,
        :photo_id => photo_id_from_url(url)
      ))
      Nokogiri::XML(res.body).search("rsp sizes size").select{ |n|
        n.attribute("label").value == "Original"
      }.map{ |n|
        n.attribute("source").value
      }.first
    rescue RestClient::Exception => e
      "/blank.gif"
    end

    def photo_id_from_url(url)
      url.split("/").last 
    end

    def query_string(params)
      (params.any? ? "?" : "") + params.map{ |k,v| [k, CGI.escape(v)].join("=") }.join("&")
    end
  end
end
