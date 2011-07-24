open = require 'open-uri'
redis = require 'redis'
querystring = require 'querystring'

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
        content.forEach (country) ->
          if country.name is cityName
            woeid = country.woeid
            cb woeid

getCurrentTrends = (cb) ->
  trends = []
  getWoeidFromName 'Tokyo', (woeid) ->
    open (trends_url.replace("[:woeid]", woeid)), (err, content) ->
      content[0].trends.forEach (trend) ->
        trends.push trend.name
      cb trends


refreshCurrentTrends = (cb) ->
  getCurrentTrends (trends) ->
    current_trends = trends
    cb?()


getTweet = ->
  if current_trends?
    open search_url + querystring.stringify({q: current_trends[0]}) + "&since_id=" + since_id, (err, content) ->
      if content?
        since_id = content.max_id
      console.log content

refreshCurrentTrends getTweet
setInterval refreshCurrentTrends, 1000 * 300
setInterval getTweet, 1000 * 60

