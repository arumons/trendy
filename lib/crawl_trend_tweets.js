(function() {
  var cuontry_woeid, current_trends, getCurrentTrends, getTweet, getWoeidFromName, open, querystring, redis, redis_client, refreshCurrentTrends, search_url, since_id, trends_url, woeid, woeid_url;
  open = require('open-uri');
  redis = require('redis');
  querystring = require('querystring');
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
        content[0].trends.forEach(function(trend) {
          return trends.push(trend.name);
        });
        return cb(trends);
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
    if (current_trends != null) {
      return open(search_url + querystring.stringify({
        q: current_trends[0]
      }) + "&since_id=" + since_id, function(err, content) {
        if (content != null) {
          since_id = content.max_id;
        }
        return console.log(content);
      });
    }
  };
  refreshCurrentTrends(getTweet);
  setInterval(refreshCurrentTrends, 1000 * 300);
  setInterval(getTweet, 1000 * 60);
}).call(this);
