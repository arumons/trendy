require 'open-uri'
require 'rubygems'
require 'json'
require 'pp'
require 'system_timer'
require 'redis'
require 'actiontimer'

$woeid_url = 'http://api.twitter.com/1/trends/available.json'
$trends_url = 'http://api.twitter.com/1/trends/[:woeid].json'
$search_url = 'http://search.twitter.com/search.json?'

$redis = Redis.new
$timer = ActionTimer::Timer.new

def getWoeidFromName (cityName)
  return $woeid unless $woeid.nil?
  obj = JSON.parse open($woeid_url).read
  obj.each do |country|
    if country['name'] == cityName then
      return $woeid = country['woeid']
    end
  end
end

def getCurrentTrends
  $currentTrends = []
  p $woeid
  content = JSON.parse open($trends_url.sub("[:woeid]", $woeid.to_s)).read
  content[0]['trends'].each do |trend|
    $currentTrends.push trend['name']
  end
  return $currentTrends
end

def getTweet
  unless $currentTrends.nil? then
    $currentTrends.each do |trend|
      content = JSON.parse open($search_url + "q='#{ URI.escape(trend) }'").read
      unless content.nil? then
        content['results'].each do |result|
          pp result['text']
          $redis.publish 'new_tweet', result['text']
        end
      end
    end
  end
end
  
$woeid = $redis.get 'woeid'
if $woeid.nil? then
  $woeid = getWoeidFromName 'Tokyo'
  $redis.set 'woeid', $woeid
end

getCurrentTrends
$timer.add(:period => 300){
  pp getCurrentTrends
}

$timer.add(:period => 10){
  getTweet
}

loop do
  sleep(10)
end
