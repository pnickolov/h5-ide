(function() {
  define(['MC', 'instance_parser', 'result_vo'], function(MC, instance_parser, result_vo) {
    var BundleInstance, CancelBundleTask, ConfirmProductInstance, DescribeBundleTasks, DescribeInstanceAttribute, DescribeInstanceStatus, DescribeInstances, GetConsoleOutput, GetPasswordData, ModifyInstanceAttribute, MonitorInstances, RebootInstances, ResetInstanceAttribute, RunInstances, StartInstances, StopInstances, TerminateInstances, URL, UnmonitorInstances, send_request;

    URL = '/aws/ec2/';
    send_request = function(api_name, param_ary, parser, callback) {
      var error;

      if (callback === null) {
        console.log("instance." + api_name + " callback is null");
        return false;
      }
      try {
        MC.api({
          url: URL,
          method: api_name,
          data: param_ary,
          success: function(result, return_code) {
            result_vo.aws_result = parser(result, return_code, param_ary);
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
        console.log("instance." + method + " error:" + error.toString());
      }
      return true;
    };
    RunInstances = function(username, session_id, callback) {
      send_request("RunInstances", [username, session_id], instance_parser.parserRunInstancesReturn, callback);
      return true;
    };
    StartInstances = function(username, session_id, region_name, instance_ids, callback) {
      if (instance_ids == null) {
        instance_ids = null;
      }
      send_request("StartInstances", [username, session_id, region_name, instance_ids], instance_parser.parserStartInstancesReturn, callback);
      return true;
    };
    StopInstances = function(username, session_id, region_name, instance_ids, force, callback) {
      if (instance_ids == null) {
        instance_ids = null;
      }
      if (force == null) {
        force = False;
      }
      send_request("StopInstances", [username, session_id, region_name, instance_ids, force], instance_parser.parserStopInstancesReturn, callback);
      return true;
    };
    RebootInstances = function(username, session_id, region_name, instance_ids, callback) {
      if (instance_ids == null) {
        instance_ids = null;
      }
      send_request("RebootInstances", [username, session_id, region_name, instance_ids], instance_parser.parserRebootInstancesReturn, callback);
      return true;
    };
    TerminateInstances = function(username, session_id, region_name, instance_ids, callback) {
      if (instance_ids == null) {
        instance_ids = null;
      }
      send_request("TerminateInstances", [username, session_id, region_name, instance_ids], instance_parser.parserTerminateInstancesReturn, callback);
      return true;
    };
    MonitorInstances = function(username, session_id, region_name, instance_ids, callback) {
      send_request("MonitorInstances", [username, session_id, region_name, instance_ids], instance_parser.parserMonitorInstancesReturn, callback);
      return true;
    };
    UnmonitorInstances = function(username, session_id, region_name, instance_ids, callback) {
      send_request("UnmonitorInstances", [username, session_id, region_name, instance_ids], instance_parser.parserUnmonitorInstancesReturn, callback);
      return true;
    };
    BundleInstance = function(username, session_id, region_name, instance_id, s3_bucket, callback) {
      send_request("BundleInstance", [username, session_id, region_name, instance_id, s3_bucket], instance_parser.parserBundleInstanceReturn, callback);
      return true;
    };
    CancelBundleTask = function(username, session_id, region_name, bundle_id, callback) {
      send_request("CancelBundleTask", [username, session_id, region_name, bundle_id], instance_parser.parserCancelBundleTaskReturn, callback);
      return true;
    };
    ModifyInstanceAttribute = function(username, session_id, callback) {
      send_request("ModifyInstanceAttribute", [username, session_id], instance_parser.parserModifyInstanceAttributeReturn, callback);
      return true;
    };
    ResetInstanceAttribute = function(username, session_id, region_name, instance_id, attribute_name, callback) {
      send_request("ResetInstanceAttribute", [username, session_id, region_name, instance_id, attribute_name], instance_parser.parserResetInstanceAttributeReturn, callback);
      return true;
    };
    ConfirmProductInstance = function(username, session_id, region_name, instance_id, product_code, callback) {
      send_request("ConfirmProductInstance", [username, session_id, region_name, instance_id, product_code], instance_parser.parserConfirmProductInstanceReturn, callback);
      return true;
    };
    DescribeInstances = function(username, session_id, region_name, instance_ids, filters, callback) {
      if (instance_ids == null) {
        instance_ids = null;
      }
      if (filters == null) {
        filters = null;
      }
      send_request("DescribeInstances", [username, session_id, region_name, instance_ids, filters], instance_parser.parserDescribeInstancesReturn, callback);
      return true;
    };
    DescribeInstanceStatus = function(username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token, callback) {
      if (instance_ids == null) {
        instance_ids = null;
      }
      if (include_all_instances == null) {
        include_all_instances = False;
      }
      if (max_results == null) {
        max_results = 1000;
      }
      if (next_token == null) {
        next_token = null;
      }
      send_request("DescribeInstanceStatus", [username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token], instance_parser.parserDescribeInstanceStatusReturn, callback);
      return true;
    };
    DescribeBundleTasks = function(username, session_id, region_name, bundle_ids, filters, callback) {
      if (bundle_ids == null) {
        bundle_ids = null;
      }
      if (filters == null) {
        filters = null;
      }
      send_request("DescribeBundleTasks", [username, session_id, region_name, bundle_ids, filters], instance_parser.parserDescribeBundleTasksReturn, callback);
      return true;
    };
    DescribeInstanceAttribute = function(username, session_id, region_name, instance_id, attribute_name, callback) {
      send_request("DescribeInstanceAttribute", [username, session_id, region_name, instance_id, attribute_name], instance_parser.parserDescribeInstanceAttributeReturn, callback);
      return true;
    };
    GetConsoleOutput = function(username, session_id, region_name, instance_id, callback) {
      send_request("GetConsoleOutput", [username, session_id, region_name, instance_id], instance_parser.parserGetConsoleOutputReturn, callback);
      return true;
    };
    GetPasswordData = function(username, session_id, region_name, instance_id, key_data, callback) {
      if (key_data == null) {
        key_data = null;
      }
      send_request("GetPasswordData", [username, session_id, region_name, instance_id, key_data], instance_parser.parserGetPasswordDataReturn, callback);
      return true;
    };
    return {
      RunInstances: RunInstances,
      StartInstances: StartInstances,
      StopInstances: StopInstances,
      RebootInstances: RebootInstances,
      TerminateInstances: TerminateInstances,
      MonitorInstances: MonitorInstances,
      UnmonitorInstances: UnmonitorInstances,
      BundleInstance: BundleInstance,
      CancelBundleTask: CancelBundleTask,
      ModifyInstanceAttribute: ModifyInstanceAttribute,
      ResetInstanceAttribute: ResetInstanceAttribute,
      ConfirmProductInstance: ConfirmProductInstance,
      DescribeInstances: DescribeInstances,
      DescribeInstanceStatus: DescribeInstanceStatus,
      DescribeBundleTasks: DescribeBundleTasks,
      DescribeInstanceAttribute: DescribeInstanceAttribute,
      GetConsoleOutput: GetConsoleOutput,
      GetPasswordData: GetPasswordData
    };
  });

}).call(this);
