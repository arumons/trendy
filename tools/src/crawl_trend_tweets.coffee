open = require 'open-uri'
redis = require 'redis'
querystring = require 'querystring'
begin = require 'begin.js'

woeid_url = 'http://api.twitter.com/1/trends/available.json'
trends_url = 'http://api.twitter.com/1/trends/[:woeid].json'
search_url = 'http://search.twitter.com/search.json?'

cuontry_woeid = null
current_trends = null
redis_client = redis.createClient()
woeid = null
since_id = 0

getWoeidFromName = do ->
  woeid = null
  (cityName, cb) ->
    if woeid?
      cb woeid
    else
      open woeid_url, (err, content) ->
        console.log content
        content.forEach (country) ->
          if country.name is cityName
            woeid = country.woeid
            cb woeid

getCurrentTrends = (cb) ->
  trends = []
  getWoeidFromName 'Tokyo', (woeid) ->
    open (trends_url.replace("[:woeid]", woeid)), (err, content) ->
      if content?
        content[0].trends.forEach (trend) ->
          trends.push trend.name
        cb trends


refreshCurrentTrends = (cb) ->
  getCurrentTrends (trends) ->
    current_trends = trends
    cb?()


getTweet = ->
  tweets = []
  if current_trends?
    current_trends.forEach (trend) ->
      open search_url + querystring.stringify({q: trend}) + "&since_id=" + since_id, (err, content) ->
        content.results.forEach (result) ->
          result.created_at = new Date created_at
          tweets.push result
          
    tweets.sort (a, b) ->
      a.created_at - b.created_at
    since_id = tweets[-1].id
    console.log tweets
    tweets.forEach (tweet) ->
      redis_client.publish 'new_tweet', tweet.text

refreshCurrentTrends getTweet
setInterval refreshCurrentTrends, 1000 * 300
setInterval getTweet, 1000 * 60

