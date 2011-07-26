open = require 'open-uri'
redis = require 'redis'
querystring = require 'querystring'
{begin, def} = require 'begin.js'
util = require 'util'

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
  cityName = null
  def (_cityName) ->
    cityName = _cityName
    if woeid?
      @out woeid
    else
      @_ -> open woeid_url, @next
  ._ (err, content) ->
    content.forEach (country) ->
      if country.name is cityName
        woeid = country.woeid
    @next woeid
  .end()

getCurrentTrends =
  def (woeid) ->
    @_ ->
      trends = []
      open (trends_url.replace("[:woeid]", woeid)), (err, content) =>
        if content?
          content[0].trends.forEach (trend) ->
            trends.push trend.name
        @next trends
  .end()

getTweet =
  def (trends) ->
    if trends?
      @map trends, (trend) ->
        console.log trend
        open search_url + querystring.stringify({q: trend}) + "&since_id=" + since_id, (err, content) =>
          util.debug err
          util.debug content

          content.results.forEach (result) =>
            result.created_at = new Date created_at
            @next result
    else
      @out()
  ._ (results) ->
    results.sort (a, b) ->
      a.created_at - b.created_at
    since_id = results[-1].id
    console.log results
    results.forEach (tweet) ->
      redis_client.publish 'new_tweet', tweet.text
    @next()
  .end()

begin ->
  @_ -> getWoeidFromName 'Tokyo'
._ (woeid) ->
  @_ -> getCurrentTrends woeid
._ (trends) ->
  @_ -> getTweet trends
.end()
