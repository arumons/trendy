(function() {
  var begin, cuontry_woeid, current_trends, getCurrentTrends, getTweet, getWoeidFromName, open, querystring, redis, redis_client, refreshCurrentTrends, search_url, since_id, trends_url, woeid, woeid_url;
  open = require('open-uri');
  redis = require('redis');
  querystring = require('querystring');
  begin = require('begin.js');
  woeid_url = 'http://api.twitter.com/1/trends/available.json';
  trends_url = 'http://api.twitter.com/1/trends/[:woeid].json';
  search_url = 'http://search.twitter.com/search.json?';
  cuontry_woeid = null;
  current_trends = null;
  redis_client = redis.createClient();
  woeid = null;
  since_id = 0;
  getWoeidFromName = (function() {
    woeid = null;
    return function(cityName, cb) {
      if (woeid != null) {
        return cb(woeid);
      } else {
        return open(woeid_url, function(err, content) {
          console.log(content);
          return content.forEach(function(country) {
            if (country.name === cityName) {
              woeid = country.woeid;
              return cb(woeid);
            }
          });
        });
      }
    };
  })();
  getCurrentTrends = function(cb) {
    var trends;
    trends = [];
    return getWoeidFromName('Tokyo', function(woeid) {
      return open(trends_url.replace("[:woeid]", woeid), function(err, content) {
        if (content != null) {
          content[0].trends.forEach(function(trend) {
            return trends.push(trend.name);
          });
          return cb(trends);
        }
      });
    });
  };
  refreshCurrentTrends = function(cb) {
    return getCurrentTrends(function(trends) {
      current_trends = trends;
      return typeof cb === "function" ? cb() : void 0;
    });
  };
  getTweet = function() {
    var tweets;
    tweets = [];
    if (current_trends != null) {
      current_trends.forEach(function(trend) {
        return open(search_url + querystring.stringify({
          q: trend
        }) + "&since_id=" + since_id, function(err, content) {
          return content.results.forEach(function(result) {
            result.created_at = new Date(created_at);
            return tweets.push(result);
          });
        });
      });
      tweets.sort(function(a, b) {
        return a.created_at - b.created_at;
      });
      since_id = tweets[-1].id;
      console.log(tweets);
      return tweets.forEach(function(tweet) {
        return redis_client.publish('new_tweet', tweet.text);
      });
    }
  };
  refreshCurrentTrends(getTweet);
  setInterval(refreshCurrentTrends, 1000 * 300);
  setInterval(getTweet, 1000 * 60);
}).call(this);
