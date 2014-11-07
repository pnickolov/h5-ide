(function() {
  module.exports = function(haystack, needle, i) {
    var good, j, l, n;
    if (!Buffer.isBuffer(needle)) {
      needle = new Buffer(needle);
    }
    i = i || 0;
    l = haystack.length - needle.length + 1;
    n = needle.length;
    while (i < l) {
      good = true;
      j = 0;
      while (j < n) {
        if (haystack[i + j] !== needle[j]) {
          good = false;
          break;
        }
        ++j;
      }
      if (good) {
        return i;
      }
      ++i;
    }
    return -1;
  };

}).call(this);
