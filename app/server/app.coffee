# Server-side Code
redis = require 'redis'
client = redis.createClient()

trends = null
init_tweets = []
current_tweets = []

client.subscribe 'new_tweet'
client.subscribe 'trends'

client.on 'message', (channel, message) ->
  # prepare trends
  if channel is 'trends'
    trends = JSON.parse message
    SS.publish.broadcast channel, trends
    return

  # add tweet
  tweet = JSON.parse message
  current_tweets.push tweet 
  init_tweets.push tweet 

  # prevent dupulicate
  if current_tweets[-2]? and current_tweets[-1] and current_tweets[-2].id is current_tweets[-1].id
    current_tweets.pop()
  current_tweets.shift() if current_tweets.length > 500
  init_tweets.shift() if init_tweets.length > 500

exports.actions =

  initTweets: (cb) ->
    console.log init_tweets
    cb init_tweets

  initTrends: (cb) ->
    cb trends

setInterval (->
  try
    console.log init_tweets.length
    console.log current_tweets.length
    if current_tweets.length > 0
      current_tweet = current_tweets.shift()
      init_tweets.shift() if init_tweets.length >= 30
      SS.publish.broadcast 'new_tweet', JSON.stringify current_tweet
  catch e
    console.log e), 2000

