(function() {
  var client, redis;
  redis = require('redis');
  client = redis.createClient();
  client.on('message', function(channel, message) {
    return SS.publish.broadcast('flash', message);
  });
}).call(this);
