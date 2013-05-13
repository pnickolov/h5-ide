(function() {
  define(['MC'], function(MC) {
    var guest, login, logout, set_credential;

    login = function(url, method, data, callback) {
      return MC.api({
        url: url,
        method: method,
        data: data,
        success: function(data, status) {
          return callback(data, status);
        }
      });
    };
    logout = function() {
      return alert('logout');
    };
    set_credential = function() {
      return alert('set_credential');
    };
    guest = function() {
      return alert('guest');
    };
    return {
      login: login,
      logout: logout,
      set_credential: set_credential,
      guest: guest
    };
  });

}).call(this);
