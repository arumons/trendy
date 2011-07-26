(function() {
  var begin, cuontry_woeid, current_trends, def, getCurrentTrends, getTweet, getWoeidFromName, open, querystring, redis, redis_client, search_url, since_id, trends_url, util, woeid, woeid_url, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  open = require('open-uri');
  redis = require('redis');
  querystring = require('querystring');
  _ref = require('begin.js'), begin = _ref.begin, def = _ref.def;
  util = require('util');
  woeid_url = 'http://api.twitter.com/1/trends/available.json';
  trends_url = 'http://api.twitter.com/1/trends/[:woeid].json';
  search_url = 'http://search.twitter.com/search.json?';
  cuontry_woeid = null;
  current_trends = null;
  redis_client = redis.createClient();
  woeid = null;
  since_id = 0;
  getWoeidFromName = (function() {
    var cityName;
    woeid = null;
    cityName = null;
    return def(function(_cityName) {
      cityName = _cityName;
      if (woeid != null) {
        return this.out(woeid);
      } else {
        return this._(function() {
          return open(woeid_url, this.next);
        });
      }
    })._(function(err, content) {
      content.forEach(function(country) {
        if (country.name === cityName) {
          return woeid = country.woeid;
        }
      });
      return this.next(woeid);
    }).end();
  })();
  getCurrentTrends = def(function(woeid) {
    return this._(function() {
      var trends;
      trends = [];
      return open(trends_url.replace("[:woeid]", woeid), __bind(function(err, content) {
        if (content != null) {
          content[0].trends.forEach(function(trend) {
            return trends.push(trend.name);
          });
        }
        return this.next(trends);
      }, this));
    });
  }).end();
  getTweet = def(function(trends) {
    if (trends != null) {
      return this.map(trends, function(trend) {
        console.log(trend);
        return open(search_url + querystring.stringify({
          q: trend
        }) + "&since_id=" + since_id, __bind(function(err, content) {
          util.debug(err);
          util.debug(content);
          return content.results.forEach(__bind(function(result) {
            result.created_at = new Date(created_at);
            return this.next(result);
          }, this));
        }, this));
      });
    } else {
      return this.out();
    }
  })._(function(results) {
    results.sort(function(a, b) {
      return a.created_at - b.created_at;
    });
    since_id = results[-1].id;
    console.log(results);
    results.forEach(function(tweet) {
      return redis_client.publish('new_tweet', tweet.text);
    });
    return this.next();
  }).end();
  begin(function() {
    return this._(function() {
      return getWoeidFromName('Tokyo');
    });
  })._(function(woeid) {
    return this._(function() {
      return getCurrentTrends(woeid);
    });
  })._(function(trends) {
    return this._(function() {
      return getTweet(trends);
    });
  }).end();
}).call(this);
