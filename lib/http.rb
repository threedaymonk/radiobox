require "uri"
require "net/http"

module HTTP
  def self.head(url)
    u = URI.parse(url)
    Net::HTTP.start(u.host, u.port) do |http|
      response = http.request_head([u.path, u.query].join("?"))
    end
  end
end
