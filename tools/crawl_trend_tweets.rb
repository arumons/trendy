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

$max_id = 0

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
  $redis.publish 'trends', JSON.generate($currentTrends)
  return $currentTrends
end

def getTweet
  unless $currentTrends.nil? then
    tweets = []
    # get tweets from trends
    $currentTrends.each do |trend|
      pp $search_url + "q='#{ URI.escape(trend) }'" + "&since_id=#{ $max_id }"
      content = JSON.parse open($search_url + "q='#{ URI.escape(trend) }'" + "&since_id=#{ $max_id }").read
      pp content
      unless content.nil? then
        content['results'].each do |result|
          tweets.push result
        end
      end
    end

    # sort
    tweets.sort! do |a, b|
      a['created_at'] <=> b['created_at']   
    end

    $max_id = tweets[-1]['id_str']

    # publish
    tweets.each do |tweet|
      $redis.publish 'new_tweet', JSON.generate(tweet)
    end
  end
end
  
$woeid = $redis.get 'woeid'
if $woeid.nil? then
  $woeid = getWoeidFromName '東京'
  $redis.set 'woeid', $woeid
end

getCurrentTrends
getTweet

$count = 0
$timer.add(:period => 250){
  $count += 1
  if $count % 7 == 0 
    $count = 0
    getCurrentTrends
  end
  getTweet
}

loop do
  sleep(10)
end
