#*************************************************************************************
#* Filename     : securitygroup_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:19
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/ec2/securitygroup/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

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
					param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
					aws_result = {}
					aws_result = parser result, return_code, param_ary

					callback aws_result

				error : ( result, return_code ) ->

					aws_result = {}
					aws_result.return_code      = return_code
					aws_result.is_error         = true
					aws_result.error_message    = result.toString()

					callback aws_result
			}

		catch error
			console.log "securitygroup." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for CreateSecurityGroup return  /////////////////
	#private (parser CreateSecurityGroup return)
	parserCreateSecurityGroupReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserCreateSecurityGroupReturn


	#///////////////// Parser for DeleteSecurityGroup return  /////////////////
	#private (parser DeleteSecurityGroup return)
	parserDeleteSecurityGroupReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDeleteSecurityGroupReturn


	#///////////////// Parser for AuthorizeSecurityGroupIngress return  /////////////////
	#private (parser AuthorizeSecurityGroupIngress return)
	parserAuthorizeSecurityGroupIngressReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserAuthorizeSecurityGroupIngressReturn


	#///////////////// Parser for RevokeSecurityGroupIngress return  /////////////////
	#private (parser RevokeSecurityGroupIngress return)
	parserRevokeSecurityGroupIngressReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserRevokeSecurityGroupIngressReturn


	#///////////////// Parser for DescribeSecurityGroups return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeSecurityGroupsResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeSecurityGroupsResponse.securityGroupInfo

	#private (parser DescribeSecurityGroups return)
	parserDescribeSecurityGroupsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeSecurityGroupsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeSecurityGroupsReturn


	#############################################################

	#def CreateSecurityGroup(self, username, session_id, region_name, group_name, group_desc, vpc_id=None):
	CreateSecurityGroup = ( src, username, session_id, region_name, group_name, group_desc, vpc_id=null, callback ) ->
		send_request "CreateSecurityGroup", src, [ username, session_id, region_name, group_name, group_desc, vpc_id ], parserCreateSecurityGroupReturn, callback
		true

	#def DeleteSecurityGroup(self, username, session_id, region_name, group_name=None, group_id=None):
	DeleteSecurityGroup = ( src, username, session_id, region_name, group_name=null, group_id=null, callback ) ->
		send_request "DeleteSecurityGroup", src, [ username, session_id, region_name, group_name, group_id ], parserDeleteSecurityGroupReturn, callback
		true

	#def AuthorizeSecurityGroupIngress(self, username, session_id, region_name,
	AuthorizeSecurityGroupIngress = ( src, username, session_id, callback ) ->
		send_request "AuthorizeSecurityGroupIngress", src, [ username, session_id ], parserAuthorizeSecurityGroupIngressReturn, callback
		true

	#def RevokeSecurityGroupIngress(self, username, session_id, region_name,
	RevokeSecurityGroupIngress = ( src, username, session_id, callback ) ->
		send_request "RevokeSecurityGroupIngress", src, [ username, session_id ], parserRevokeSecurityGroupIngressReturn, callback
		true

	#def DescribeSecurityGroups(self, username, session_id, region_name, group_names=None, group_ids=None, filters=None):
	DescribeSecurityGroups = ( src, username, session_id, region_name, group_names=null, group_ids=null, filters=null, callback ) ->
		send_request "DescribeSecurityGroups", src, [ username, session_id, region_name, group_names, group_ids, filters ], parserDescribeSecurityGroupsReturn, callback
		true


	#############################################################
	#public
	CreateSecurityGroup          : CreateSecurityGroup
	DeleteSecurityGroup          : DeleteSecurityGroup
	AuthorizeSecurityGroupIngress : AuthorizeSecurityGroupIngress
	RevokeSecurityGroupIngress   : RevokeSecurityGroupIngress
	DescribeSecurityGroups       : DescribeSecurityGroups
	#
	resolveDescribeSecurityGroupsResult : resolveDescribeSecurityGroupsResult

