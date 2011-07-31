# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

messageQueue = []

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->

  SS.events.on 'flash', (message) ->
    messageQueue.push message if messageQueue.length < 100

#  setInterval ->
#    $('#tweets').prepend("<div class='tweet'>#{ messageQueue.shift() }</div>") if messageQueue.length > 0
#   , 1000

  setInterval ->
    $('#templates-tweet').tmpl({tweet: messageQueue.shift()}).prependTo('#tweets') if messageQueue.length > 0
   , 1000
