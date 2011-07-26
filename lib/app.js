(function() {
  var client, redis;
  redis = require('redis');
  client = redis.createClient();
  client.subscribe('new_tweet');
  client.on('message', function(channel, message) {
    return SS.publish.broadcast('flash', message);
  });
}).call(this);
