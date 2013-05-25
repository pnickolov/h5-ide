(function() {
  define(['instance_vo', 'result_vo', 'constant'], function(instance_vo, result_vo, constant) {
    var parserBundleInstanceReturn, parserCancelBundleTaskReturn, parserConfirmProductInstanceReturn, parserDescribeBundleTasksReturn, parserDescribeInstanceAttributeReturn, parserDescribeInstanceStatusReturn, parserDescribeInstancesReturn, parserGetConsoleOutputReturn, parserGetPasswordDataReturn, parserModifyInstanceAttributeReturn, parserMonitorInstancesReturn, parserRebootInstancesReturn, parserResetInstanceAttributeReturn, parserRunInstancesReturn, parserStartInstancesReturn, parserStopInstancesReturn, parserTerminateInstancesReturn, parserUnmonitorInstancesReturn, resolveDescribeBundleTasksResult, resolveDescribeInstanceAttributeResult, resolveDescribeInstanceStatusResult, resolveDescribeInstancesResult, resolveGetConsoleOutputResult, resolveGetPasswordDataResult;

    parserRunInstancesReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserStartInstancesReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserStopInstancesReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserRebootInstancesReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserTerminateInstancesReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserMonitorInstancesReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserUnmonitorInstancesReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserBundleInstanceReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserCancelBundleTaskReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserModifyInstanceAttributeReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserResetInstanceAttributeReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    parserConfirmProductInstanceReturn = function(result, return_code, param) {
      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      return result_vo.aws_result;
    };
    resolveDescribeInstancesResult = function(result) {};
    parserDescribeInstancesReturn = function(result, return_code, param) {
      var resolved_data;

      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      if (return_code === constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error) {
        resolved_data = resolveDescribeInstancesResult(result);
        result_vo.aws_result.resolved_data = resolved_data;
      }
      return result_vo.aws_result;
    };
    resolveDescribeInstanceStatusResult = function(result) {};
    parserDescribeInstanceStatusReturn = function(result, return_code, param) {
      var resolved_data;

      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      if (return_code === constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error) {
        resolved_data = resolveDescribeInstanceStatusResult(result);
        result_vo.aws_result.resolved_data = resolved_data;
      }
      return result_vo.aws_result;
    };
    resolveDescribeBundleTasksResult = function(result) {};
    parserDescribeBundleTasksReturn = function(result, return_code, param) {
      var resolved_data;

      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      if (return_code === constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error) {
        resolved_data = resolveDescribeBundleTasksResult(result);
        result_vo.aws_result.resolved_data = resolved_data;
      }
      return result_vo.aws_result;
    };
    resolveDescribeInstanceAttributeResult = function(result) {};
    parserDescribeInstanceAttributeReturn = function(result, return_code, param) {
      var resolved_data;

      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      if (return_code === constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error) {
        resolved_data = resolveDescribeInstanceAttributeResult(result);
        result_vo.aws_result.resolved_data = resolved_data;
      }
      return result_vo.aws_result;
    };
    resolveGetConsoleOutputResult = function(result) {};
    parserGetConsoleOutputReturn = function(result, return_code, param) {
      var resolved_data;

      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      if (return_code === constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error) {
        resolved_data = resolveGetConsoleOutputResult(result);
        result_vo.aws_result.resolved_data = resolved_data;
      }
      return result_vo.aws_result;
    };
    resolveGetPasswordDataResult = function(result) {};
    parserGetPasswordDataReturn = function(result, return_code, param) {
      var resolved_data;

      result_vo.aws_result = result_vo.processAWSReturnHandler(result, return_code, param);
      if (return_code === constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error) {
        resolved_data = resolveGetPasswordDataResult(result);
        result_vo.aws_result.resolved_data = resolved_data;
      }
      return result_vo.aws_result;
    };
    return {
      parserRunInstancesReturn: parserRunInstancesReturn,
      parserStartInstancesReturn: parserStartInstancesReturn,
      parserStopInstancesReturn: parserStopInstancesReturn,
      parserRebootInstancesReturn: parserRebootInstancesReturn,
      parserTerminateInstancesReturn: parserTerminateInstancesReturn,
      parserMonitorInstancesReturn: parserMonitorInstancesReturn,
      parserUnmonitorInstancesReturn: parserUnmonitorInstancesReturn,
      parserBundleInstanceReturn: parserBundleInstanceReturn,
      parserCancelBundleTaskReturn: parserCancelBundleTaskReturn,
      parserModifyInstanceAttributeReturn: parserModifyInstanceAttributeReturn,
      parserResetInstanceAttributeReturn: parserResetInstanceAttributeReturn,
      parserConfirmProductInstanceReturn: parserConfirmProductInstanceReturn,
      parserDescribeInstancesReturn: parserDescribeInstancesReturn,
      parserDescribeInstanceStatusReturn: parserDescribeInstanceStatusReturn,
      parserDescribeBundleTasksReturn: parserDescribeBundleTasksReturn,
      parserDescribeInstanceAttributeReturn: parserDescribeInstanceAttributeReturn,
      parserGetConsoleOutputReturn: parserGetConsoleOutputReturn,
      parserGetPasswordDataReturn: parserGetPasswordDataReturn
    };
  });

}).call(this);
