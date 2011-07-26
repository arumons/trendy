require 'open-uri'
require 'rubygems'
require 'json'

$woeid = nil

$woeid_url = 'http://api.twitter.com/1/trends/available.json'
$trends_url = 'http://api.twitter.com/1/trends/[:woeid].json'
$search_url = 'http://search.twitter.com/search.json?'

def getWoeidFromName (city_name)
  return unless $woeid.nil?
  content = open($woeid_url).read
  obj = JSON.parse content
  p obj
end

getWoeidFromName 'a'

