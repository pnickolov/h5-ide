(function() {
  define(['jquery', 'MC', 'constant'], function($, MC, constant) {
    var checkAllCookie, clearInvalidCookie, clearV2Cookie, deleteCookie, getCookieByName, getIDECookie, setCookie, setCookieByName, setCred, setIDECookie;
    setCookie = function(result) {
      var option;
      if (document.domain.indexOf('madeiracloud.com') !== -1) {
        option = constant.COOKIE_OPTION;
      } else {
        option = constant.LOCAL_COOKIE_OPTION;
      }
      $.cookie('userid', result.userid, option);
      $.cookie('usercode', result.usercode, option);
      $.cookie('session_id', result.session_id, option);
      $.cookie('region_name', result.region_name, option);
      $.cookie('email', result.email, option);
      $.cookie('has_cred', result.has_cred, option);
      $.cookie('username', MC.base64Decode(result.usercode), option);
      $.cookie('account_id', result.account_id, option);
      $.cookie('state', result.state, option);
      return $.cookie('is_invitated', result.is_invitated, option);
    };
    deleteCookie = function() {
      var option;
      if (document.domain.indexOf('madeiracloud.com') !== -1) {
        option = constant.COOKIE_OPTION;
      } else {
        option = constant.LOCAL_COOKIE_OPTION;
      }
      $.cookie('userid', '', option);
      $.cookie('usercode', '', option);
      $.cookie('session_id', '', option);
      $.cookie('region_name', '', option);
      $.cookie('email', '', option);
      $.cookie('has_cred', '', option);
      $.cookie('username', '', option);
      $.cookie('account_id', '', option);
      $.cookie('state', '', option);
      $.cookie('is_invitated', '', option);
      return $.cookie('madeiracloud_ide_session_id', '', option);
    };
    setCred = function(result) {
      var option;
      if (document.domain.indexOf('madeiracloud.com') !== -1) {
        option = constant.COOKIE_OPTION;
      } else {
        option = constant.LOCAL_COOKIE_OPTION;
      }
      return $.cookie('has_cred', result, option);
    };
    setIDECookie = function(result) {
      var madeiracloud_ide_session_id, option;
      if (document.domain.indexOf('madeiracloud.com') !== -1) {
        option = constant.COOKIE_OPTION;
      } else {
        option = constant.LOCAL_COOKIE_OPTION;
      }
      madeiracloud_ide_session_id = [result.userid, result.usercode, result.session_id, result.region_name, result.email, result.has_cred, result.account_id, result.state, result.is_invitated];
      $.cookie('madeiracloud_ide_session_id', MC.base64Encode(JSON.stringify(madeiracloud_ide_session_id)), option);
      return null;
    };
    getIDECookie = function() {
      var err, madeiracloud_ide_session_id, result;
      result = null;
      madeiracloud_ide_session_id = $.cookie('madeiracloud_ide_session_id');
      if (madeiracloud_ide_session_id) {
        try {
          result = JSON.parse(MC.base64Decode(madeiracloud_ide_session_id));
        } catch (_error) {
          err = _error;
          result = null;
        }
      }
      if (result && $.type(result === "array" && result.length === 8)) {
        return {
          userid: result[0],
          usercode: result[1],
          session_id: result[2],
          region_name: result[3],
          email: result[4],
          has_cred: result[5],
          account_id: result[6],
          state: result[7],
          is_invitated: result[8]
        };
      } else {
        return null;
      }
    };
    checkAllCookie = function() {
      if ($.cookie('username') && $.cookie('userid') && $.cookie('usercode') && $.cookie('session_id') && $.cookie('region_name') && $.cookie('has_cred') && $.cookie('email') && $.cookie('account_id')) {
        return true;
      } else {
        return false;
      }
    };
    clearV2Cookie = function(path) {
      var option;
      option = {
        path: path
      };
      return $.each($.cookie(), function(key, cookie_name) {
        $.removeCookie(cookie_name, option);
        return null;
      });
    };
    clearInvalidCookie = function() {
      var option;
      option = {
        domain: 'ide.madeiracloud.com',
        path: '/'
      };
      return $.each($.cookie(), function(key, cookie_name) {
        $.removeCookie(cookie_name, option);
        return null;
      });
    };
    getCookieByName = function(cookie_name) {
      return $.cookie(cookie_name);
    };
    setCookieByName = function(cookie_name, value) {
      var option;
      if (document.domain.indexOf('madeiracloud.com') !== -1) {
        option = constant.COOKIE_OPTION;
      } else {
        option = constant.LOCAL_COOKIE_OPTION;
      }
      return $.cookie(cookie_name, value, option);
    };
    return {
      setCookie: setCookie,
      deleteCookie: deleteCookie,
      setIDECookie: setIDECookie,
      getIDECookie: getIDECookie,
      setCred: setCred,
      checkAllCookie: checkAllCookie,
      clearV2Cookie: clearV2Cookie,
      clearInvalidCookie: clearInvalidCookie,
      getCookieByName: getCookieByName,
      setCookieByName: setCookieByName
    };
  });

}).call(this);
