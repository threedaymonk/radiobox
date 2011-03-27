require "rest_client"
require "cgi"
require "json"

class Hash
  def recursive_find_by_key(key)
    stack = [ self ]
    while (to_search = stack.pop)
      to_search.each do |k, v|
        return v if (k == key)
        if (v.respond_to?(:recursive_find_by_key))
          stack << v
        end
      end
    end
  end
end

module Wikipedia
  class API
    BASE = "http://dbpedialite.org/titles/"

    def fetch(wikipedia_url)
      url = BASE + id_from_url(wikipedia_url)
      begin
        res = RestClient.get(url, {:accept => :json})
        data = JSON.parse(res)
      rescue
        return nil
      end
    end

    def comment(wikipedia_url)
      data = self.fetch(wikipedia_url)
      if data
        comment = data.recursive_find_by_key('http://www.w3.org/2000/01/rdf-schema#comment')
        if comment
          return comment.first["value"]
        end
      end
      nil
    end

    def id_from_url(url)
      url.split("/").last
    end
  end
end
