(function() {
  var messageQueue;
  SS.socket.on('disconnect', function() {
    return $('#message').text('SocketStream server is down :-(');
  });
  SS.socket.on('reconnect', function() {
    return $('#message').text('SocketStream server is up :-)');
  });
  messageQueue = [];
  exports.init = function() {
    SS.events.on('flash', function(message) {
      if (messageQueue.length < 100) {
        return messageQueue.push(message);
      }
    });
    return setInterval(function() {
      if (messageQueue.length > 0) {
        return $('#templates-tweet').tmpl({
          tweet: messageQueue.shift()
        }).prependTo('#tweets');
      }
    }, 1000);
  };
}).call(this);
