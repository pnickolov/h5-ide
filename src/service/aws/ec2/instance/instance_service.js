/*
Description:
    service know back-end api
Action:
    1.invoke MC.api (send url, method, data)
    2.invoke parser
    3.invoke callback
*/


(function() {
  define(['MC', 'instance_parser', 'result_vo'], function(MC, instance_parser, result_vo) {
    var DescribeInstances, URL;

    URL = '/aws/ec2/instance/';
    DescribeInstances = function(username, session_id, region_name, instance_ids, filters, callback) {
      var error, param;

      if (instance_ids == null) {
        instance_ids = null;
      }
      if (filters == null) {
        filters = null;
      }
      if (callback === null) {
        console.log("instance_service.DescribeInstances callback is null");
        return false;
      }
      try {
        param = [username, session_id, region_name, instance_ids, filters];
        MC.api({
          url: URL,
          method: 'DescribeInstances',
          data: param,
          success: function(result, return_code) {
            result_vo.aws_result = instance_parser.parseDescribeInstancesResponse(result, return_code, param);
            return callback(result_vo.aws_result);
          },
          error: function(result, return_code) {
            result_vo.aws_result.return_code = return_code;
            result_vo.aws_result.is_error = true;
            result_vo.aws_result.error_message = result.toString();
            return callback(result_vo.aws_result);
          }
        });
      } catch (_error) {
        error = _error;
        console.log("instance_service.DescribeInstances error:" + error.toString());
      }
      return true;
    };
    return {
      DescribeInstances: DescribeInstances
    };
  });

}).call(this);
