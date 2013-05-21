(function() {
  define(['session_vo', 'result_vo', 'constant'], function(session_vo, result_vo, constant) {
    var parseLoginResult, resolveVO;

    resolveVO = function(result) {
      session_vo.session_info.userid = result[0];
      session_vo.session_info.usercode = result[1];
      session_vo.session_info.session_id = result[2];
      session_vo.session_info.region_name = result[3];
      session_vo.session_info.email = result[4];
      session_vo.session_info.has_cred = result[5];
      return session_vo.session_info;
    };
    parseLoginResult = function(result, return_code, param) {
      var error, error_message, is_error, resolved_data;

      is_error = true;
      error_message = "";
      resolved_data = null;
      try {
        switch (return_code) {
          case constant.RETURN_CODE.E_OK:
            resolved_data = resolveVO(result);
            is_error = false;
            break;
          case constant.RETURN_CODE.E_NONE:
            error_message = result.toString();
            break;
          case constant.RETURN_CODE.E_INVALID:
            error_message = result.toString();
            break;
          case constant.RETURN_CODE.E_EXPIRED:
            error_message = result.toString();
            break;
          case constant.RETURN_CODE.E_UNKNOWN:
            error_message = constant.MESSAGE_E.E_UNKNOWN;
            break;
          default:
            error_message = result.toString();
        }
      } catch (_error) {
        error = _error;
        error_message = error.toString();
        is_error = true;
      } finally {
        result_vo.forge_result.return_code = return_code;
        result_vo.forge_result.param = param;
        result_vo.forge_result.is_error = is_error;
        result_vo.forge_result.resolved_data = resolved_data;
        result_vo.forge_result.error_message = error_message;
      }
      return result_vo.forge_result;
    };
    return {
      parseLoginResult: parseLoginResult
    };
  });

}).call(this);
