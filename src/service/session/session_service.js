/*
Description:
	service know back-end api
Action:
	1.invoke MC.api (send url, method, data)
	2.invoke parser
	3.invoke callback
*/


(function() {
  define(['MC', 'session_parser', 'result_vo'], function(MC, session_parser, result_vo) {
    var URL, guest, login, logout, setCredential;

    URL = '/session/';
    login = function(username, password, callback) {
      var error, param;

      if (callback === null) {
        console.log("session_service.login callback is null");
        return false;
      }
      try {
        param = [username, password];
        MC.api({
          url: URL,
          method: 'login',
          data: param,
          success: function(result, return_code) {
            result_vo.forge_result = session_parser.parseLoginResult(result, return_code, param);
            return callback(result_vo.forge_result);
          },
          error: function(result, return_code) {
            result_vo.forge_result.return_code = return_code;
            result_vo.forge_result.is_error = true;
            result_vo.forge_result.error_message = result.toString();
            return callback(result_vo.forge_result);
          }
        });
      } catch (_error) {
        error = _error;
        console.log("session_service.login error:" + error.toString());
      }
      return true;
    };
    logout = function(callback, username, session_id) {
      return alert('logout');
    };
    setCredential = function(callback, username, session_id, access_key, secret_key, account_id) {
      if (account_id == null) {
        account_id = null;
      }
      return alert('setCredential');
    };
    guest = function(callback, guest_id, guestname) {
      return alert('guest');
    };
    return {
      login: login,
      logout: logout,
      setCredential: setCredential,
      guest: guest
    };
  });

}).call(this);
