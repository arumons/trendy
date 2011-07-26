# Server-side Code
redis = require 'redis'
client = redis.createClient()

client.subscribe 'new_tweet'
client.on 'message', (channel, message) ->
  SS.publish.broadcast 'flash', message


