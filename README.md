Getting started
===============

Set environment variables for configuration:

* `SOUNDCLOUD_CLIENT_ID`: Soundcloud API client ID
* `SOUNDCLOUD_USER_WHITELIST`: Space-separated list of users whose comments will be shown
* `FLICKR_API_KEY`: Flickr API key

Then:

    bundle install

    bundle exec shotgun -p 9292 config.ru

Then visit [http://localhost:9292/](http://localhost:9292/).

Prerequisites
-------------

* memcached must be running
