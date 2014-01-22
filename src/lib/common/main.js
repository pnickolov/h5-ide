(function() {
  define(['MC', 'lib/common/cookie', 'lib/common/other'], function(MC, cookie, other) {
    return MC.common = {
      cookie: cookie,
      other: other
    };
  });

}).call(this);
