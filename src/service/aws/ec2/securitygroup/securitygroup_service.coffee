#*************************************************************************************
#* Filename     : securitygroup_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:14
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'securitygroup_parser', 'result_vo' ], ( MC, securitygroup_parser, result_vo ) ->

    URL = '/aws/ec2/securitygroup/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "securitygroup." + api_name + " callback is null"
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
            console.log "securitygroup." + method + " error:" + error.toString()


        true
    # end of send_request

    #def CreateSecurityGroup(self, username, session_id, region_name, group_name, group_desc, vpc_id=None):
    CreateSecurityGroup = ( username, session_id, region_name, group_name, group_desc, vpc_id=null, callback ) ->
        send_request "CreateSecurityGroup", [ username, session_id, region_name, group_name, group_desc, vpc_id ], securitygroup_parser.parserCreateSecurityGroupReturn, callback
        true

    #def DeleteSecurityGroup(self, username, session_id, region_name, group_name=None, group_id=None):
    DeleteSecurityGroup = ( username, session_id, region_name, group_name=null, group_id=null, callback ) ->
        send_request "DeleteSecurityGroup", [ username, session_id, region_name, group_name, group_id ], securitygroup_parser.parserDeleteSecurityGroupReturn, callback
        true

    #def AuthorizeSecurityGroupIngress(self, username, session_id, region_name,
    AuthorizeSecurityGroupIngress = ( username, session_id, callback ) ->
        send_request "AuthorizeSecurityGroupIngress", [ username, session_id ], securitygroup_parser.parserAuthorizeSecurityGroupIngressReturn, callback
        true

    #def RevokeSecurityGroupIngress(self, username, session_id, region_name,
    RevokeSecurityGroupIngress = ( username, session_id, callback ) ->
        send_request "RevokeSecurityGroupIngress", [ username, session_id ], securitygroup_parser.parserRevokeSecurityGroupIngressReturn, callback
        true

    #def DescribeSecurityGroups(self, username, session_id, region_name, group_names=None, group_ids=None, filters=None):
    DescribeSecurityGroups = ( username, session_id, region_name, group_names=null, group_ids=null, filters=null, callback ) ->
        send_request "DescribeSecurityGroups", [ username, session_id, region_name, group_names, group_ids, filters ], securitygroup_parser.parserDescribeSecurityGroupsReturn, callback
        true


    #############################################################
    #public
    CreateSecurityGroup          : CreateSecurityGroup
    DeleteSecurityGroup          : DeleteSecurityGroup
    AuthorizeSecurityGroupIngress : AuthorizeSecurityGroupIngress
    RevokeSecurityGroupIngress   : RevokeSecurityGroupIngress
    DescribeSecurityGroups       : DescribeSecurityGroups

