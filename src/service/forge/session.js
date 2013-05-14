(function() {
  define(['MC', 'vo', 'parser'], function(MC, vo, parser) {
    var guest, login, logout, set_credential;

    login = function(url, method, param, callback) {
      return MC.api({
        url: url,
        method: method,
        data: param,
        success: function(result, status) {
          vo.user_vo = parser.parser_user_vo(result);
          return callback(vo.user_vo, status, param);
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
