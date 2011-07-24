(function() {
  var client1, redis;
  redis = require('redis');
  client1 = redis.createClient();
  client1.subscribe('trend_tweet');
  client1.on('message', function(channel, message) {
    return console.log(message);
  });
}).call(this);
