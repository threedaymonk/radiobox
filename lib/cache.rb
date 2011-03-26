require "dalli"
require "digest/sha1"

class Cache
  def initialize
    @client = Dalli::Client.new
  end

  def get(k)
    @client.get(make_key(k))
  end

  def set(k, v)
    @client.set(make_key(k), v)
  end

  def make_key(k)
    Digest::SHA1.hexdigest(k)
  end

  def wrap(object)
    Wrapper.new(object, self)
  end

  class Wrapper
    def initialize(object, cache)
      @object = object
      @cache  = cache
    end

    def method_missing(*args)
      k = args.inspect
      @cache.get(k) || @object.__send__(*args).tap{ |result|
        @cache.set(k, result)
      }
    end
  end
end
