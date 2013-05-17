(function() {
  define([], function() {
    var aws_result_vo, forge_result_vo;

    forge_result_vo = {
      return_code: -1,
      param: null,
      resolved_data: null,
      resolved_message: "",
      is_error: true
    };
    aws_result_vo = {
      param: null,
      resolved_data: null,
      is_error: true,
      error_code: null,
      error_message: null
    };
    return {
      forge_result_vo: forge_result_vo,
      aws_result_vo: aws_result_vo
    };
  });

}).call(this);
