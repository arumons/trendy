(function() {
  var d1, d2, date_1, date_2, ds;
  date_1 = 'Mon, 25 Jul 2011 13:00:05 +0000';
  date_2 = 'Mon, 25 Jul 2011 13:00:04 +0000';
  d1 = new Date(date_1);
  d2 = new Date(date_2);
  ds = [d2, d1];
  console.log(d1 - d2);
  ds.sort(function(a, b) {
    return a - b;
  });
  console.log(ds);
}).call(this);
