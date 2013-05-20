(function() {
  define(['MC', 'jquery', 'instance_vo', 'result_vo', 'constant'], function(MC, $, instance_vo, result_vo, constant) {
    var parseDescribeInstancesResponse, resolveVO;

    resolveVO = function(result) {
      var xml;

      xml = $.parseXML(result);
      instance_vo.instance = $.xml2json(xml);
      return instance_vo.instance;
    };
    parseDescribeInstancesResponse = function(result, return_code, param) {
      var aws_error_code, aws_error_message, error, error_message, is_error, resolved_data;

      is_error = true;
      error_message = "";
      resolved_data = null;
      aws_error_code = -1;
      aws_error_message = "";
      try {
        switch (return_code) {
          case constant.RETURN_CODE.E_OK:
            resolved_data = resolveVO(result[1]);
            is_error = false;
            break;
          default:
            console.log(result.toString());
        }
      } catch (_error) {
        error = _error;
        is_error = true;
        console.log(error.toString());
      } finally {
        result_vo.aws_result.return_code = return_code;
        result_vo.aws_result.param = param;
        result_vo.aws_result.is_error = is_error;
        result_vo.aws_result.resolved_data = resolved_data;
        result_vo.aws_result.error_message = error_message;
        result_vo.aws_result.aws_error_code = aws_error_code;
        result_vo.aws_result.aws_error_message = aws_error_message;
      }
      return result_vo.aws_result;
    };
    return {
      parseDescribeInstancesResponse: parseDescribeInstancesResponse
    };
  });

}).call(this);
