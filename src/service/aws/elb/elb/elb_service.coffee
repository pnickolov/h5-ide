#*************************************************************************************
#* Filename     : elb_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:15
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'elb_parser', 'result_vo' ], ( MC, elb_parser, result_vo ) ->

    URL = '/aws/elb/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "elb." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "elb." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeInstanceHealth(self, username, session_id, region_name, elb_name, instance_ids=None):
    DescribeInstanceHealth = ( username, session_id, region_name, elb_name, instance_ids=null, callback ) ->
        send_request "DescribeInstanceHealth", [ username, session_id, region_name, elb_name, instance_ids ], elb_parser.parserDescribeInstanceHealthReturn, callback
        true

    #def DescribeLoadBalancerPolicies(self, username, session_id, region_name, elb_name=None, policy_names=None):
    DescribeLoadBalancerPolicies = ( username, session_id, region_name, elb_name=null, policy_names=null, callback ) ->
        send_request "DescribeLoadBalancerPolicies", [ username, session_id, region_name, elb_name, policy_names ], elb_parser.parserDescribeLoadBalancerPoliciesReturn, callback
        true

    #def DescribeLoadBalancerPolicyTypes(self, username, session_id, region_name, policy_type_names=None):
    DescribeLoadBalancerPolicyTypes = ( username, session_id, region_name, policy_type_names=null, callback ) ->
        send_request "DescribeLoadBalancerPolicyTypes", [ username, session_id, region_name, policy_type_names ], elb_parser.parserDescribeLoadBalancerPolicyTypesReturn, callback
        true

    #def DescribeLoadBalancers(self, username, session_id, region_name, elb_names=None, marker=None):
    DescribeLoadBalancers = ( username, session_id, region_name, elb_names=null, marker=null, callback ) ->
        send_request "DescribeLoadBalancers", [ username, session_id, region_name, elb_names, marker ], elb_parser.parserDescribeLoadBalancersReturn, callback
        true


    #############################################################
    #public
    DescribeInstanceHealth       : DescribeInstanceHealth
    DescribeLoadBalancerPolicies : DescribeLoadBalancerPolicies
    DescribeLoadBalancerPolicyTypes : DescribeLoadBalancerPolicyTypes
    DescribeLoadBalancers        : DescribeLoadBalancers

