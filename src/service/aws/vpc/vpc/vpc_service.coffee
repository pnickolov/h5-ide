#*************************************************************************************
#* Filename     : vpc_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:25
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/vpc/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "vpc." + api_name + " callback is null"
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
			console.log "vpc." + api_name + " error:" + error.toString()


		true
	# end of send_request

	resolvedObjectToArray = ( objs ) ->

		if $.type(objs)  == "array"

			for obj in objs

				obj = resolvedObjectToArray obj

		if $.type(objs)  == "object"

			if $.isEmptyObject objs

				objs = null

			for key, value of objs

				if key == 'item' and $.type(value)  == "object"

					tmp = []

					tmp.push resolvedObjectToArray value

					objs[key] = tmp

				else if $.type(value)  == "object" or $.type(value)  == "array"

					objs[key] = resolvedObjectToArray value

		objs

	#///////////////// Parser for DescribeVpcs return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeVpcsResult = ( result ) ->
		#return

		result_set = ($.xml2json ($.parseXML result[1])).DescribeVpcsResponse.vpcSet

		result = resolvedObjectToArray result_set

		if result?.item?

			return result.item

		else

			return null


	#private (parser DescribeVpcs return)
	parserDescribeVpcsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeVpcsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeVpcsReturn


	#///////////////// Parser for DescribeAccountAttributes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAccountAttributesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		res = {}

		if (result[1] instanceof Object)
			res[region] = ($.xml2json ($.parseXML node)).DescribeAccountAttributesResponse for region, node of result[1]
		else
			res = ($.xml2json ($.parseXML result[1])).DescribeAccountAttributesResponse

		res

	#private (parser DescribeAccountAttributes return)
	parserDescribeAccountAttributesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAccountAttributesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAccountAttributesReturn


	#///////////////// Parser for DescribeVpcAttribute return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeVpcAttributeResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeVpcAttributeResponse


	#private (parser DescribeVpcAttribute return)
	parserDescribeVpcAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeVpcAttributeResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeVpcAttributeReturn


	#############################################################

	#def DescribeVpcs(self, username, session_id, region_name, vpc_ids=None, filters=None):
	DescribeVpcs = ( src, username, session_id, region_name, vpc_ids=null, filters=null, callback ) ->
		send_request "DescribeVpcs", src, [ username, session_id, region_name, vpc_ids, filters ], parserDescribeVpcsReturn, callback
		true

	#def DescribeAccountAttributes(self, username, session_id, region_name, attribute_name):
	DescribeAccountAttributes = ( src, username, session_id, region_name, attribute_name, callback ) ->
		send_request "DescribeAccountAttributes", src, [ username, session_id, region_name, attribute_name ], parserDescribeAccountAttributesReturn, callback
		true

	#def DescribeVpcAttribute(self, username, session_id, region_name, vpc_id, attribute):
	DescribeVpcAttribute = ( src, username, session_id, region_name, vpc_id, attribute, callback ) ->
		send_request "DescribeVpcAttribute", src, [ username, session_id, region_name, vpc_id, attribute ], parserDescribeVpcAttributeReturn, callback
		true


	#############################################################
	#public
	DescribeVpcs                 : DescribeVpcs
	DescribeAccountAttributes    : DescribeAccountAttributes
	DescribeVpcAttribute         : DescribeVpcAttribute
	#
	resolveDescribeVpcsResult : resolveDescribeVpcsResult

