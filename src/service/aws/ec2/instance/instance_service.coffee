###
Description:
    service know back-end api
Action:
    1.invoke MC.api (send url, method, data)
    2.invoke parser
    3.invoke callback
###

define [ 'MC', 'instance_parser', 'result_vo' ], ( MC, instance_parser, result_vo ) ->

    URL = '/aws/ec2/instance/'

    #def DescribeInstances(self, username, session_id, region_name, instance_ids=None, filters=None):
    #private
    DescribeInstances = ( username, session_id, region_name, instance_ids = null, filters = null, callback ) ->

        #check callback
        if callback is null
            console.log "instance_service.DescribeInstances callback is null"
            return false

        try

            param = [ username, session_id, region_name, instance_ids, filters ]

            MC.api {
                url     : URL
                method  : 'DescribeInstances'
                data    : param
                success : ( result, return_code ) ->

                    #resolve result
                    result_vo.aws_result = instance_parser.parseDescribeInstancesResponse result, return_code, param

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result

            }

        catch error
            console.log "instance_service.DescribeInstances error:" + error.toString()

        true
    # end of DescribeInstances()

    #public
    DescribeInstances : DescribeInstances
