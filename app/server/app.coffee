# Server-side Code
redis = require 'redis'
client = redis.createClient()

init_trends = null
init_tweets = []

client.subscribe 'new_tweet'
client.subscribe 'trends'

client.on 'message', (channel, message) ->
  # prepare init trends
  if channel is 'trends'
    init_trends = JSON.parse message

  # preapre init tweets
  if channel is 'new_tweet'
    init_tweets.pop() if init_tweets.length > 30
    init_tweets.unshift JSON.parse message

  SS.publish.broadcast channel, message

exports.actions =

  initTweets: (cb) ->
    cb init_tweets

  initTrends: (cb) ->
    cb init_trends

