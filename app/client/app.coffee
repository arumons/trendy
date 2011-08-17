# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

messageQueue = []
previousTweetId = 0

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->

  # push new_tweet to queue
  SS.events.on 'new_tweet', (message) ->
    tweet = JSON.parse message
    messageQueue.push tweet if messageQueue.length < 2000 and previousTweetId isnt tweet.id

  # set new trends
  SS.events.on 'trend', (message) ->
    $('#trends').empty()
    $('#templates-trends').tmpl({trends: JSON.parse(message)}).prependTo('#trends')

  # add tweet to #tweets
  setInterval (->
    tweet = messageQueue.shift()
    $('.tweet:last-child').remove() if $('.tweet').size > 100
    $('#templates-tweet').tmpl(tweet).prependTo('#tweets') if messageQueue.length > 0), 3000

  # get init trends
  SS.server.app.initTrends (trends) ->
    $('#templates-trends').tmpl({trends: trends}).prependTo('#trends')

  # get init tweets
  SS.server.app.initTweets (tweets) ->
    console.log tweets
    tweets.forEach (tweet) ->
      $('#templates-tweet').tmpl(tweet).prependTo('#tweets')


