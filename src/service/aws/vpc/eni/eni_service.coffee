#*************************************************************************************
#* Filename     : eni_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:24
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/vpc/eni/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "eni." + api_name + " callback is null"
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
			console.log "eni." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for DescribeNetworkInterfaces return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeNetworkInterfacesResult = ( result ) ->
		#return
		($.xml2json ($.parseXML result[1])).DescribeNetworkInterfacesResponse.networkInterfaceSet

	#private (parser DescribeNetworkInterfaces return)
	parserDescribeNetworkInterfacesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeNetworkInterfacesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeNetworkInterfacesReturn


	#///////////////// Parser for DescribeNetworkInterfaceAttribute return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeNetworkInterfaceAttributeResult = ( result ) ->
		#return
		($.xml2json ($.parseXML result[1])).DescribeNetworkInterfaceAttributeResponse

	#private (parser DescribeNetworkInterfaceAttribute return)
	parserDescribeNetworkInterfaceAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeNetworkInterfaceAttributeResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeNetworkInterfaceAttributeReturn


	#############################################################

	#def DescribeNetworkInterfaces(self, username, session_id, region_name, eni_ids=None, filters=None):
	DescribeNetworkInterfaces = ( src, username, session_id, region_name, eni_ids=null, filters=null, callback ) ->
		send_request "DescribeNetworkInterfaces", src, [ username, session_id, region_name, eni_ids, filters ], parserDescribeNetworkInterfacesReturn, callback
		true

	#def DescribeNetworkInterfaceAttribute(self, username, session_id, region_name, eni_id, attribute):
	DescribeNetworkInterfaceAttribute = ( src, username, session_id, region_name, eni_id, attribute, callback ) ->
		send_request "DescribeNetworkInterfaceAttribute", src, [ username, session_id, region_name, eni_id, attribute ], parserDescribeNetworkInterfaceAttributeReturn, callback
		true


	#############################################################
	#public
	DescribeNetworkInterfaces    : DescribeNetworkInterfaces
	DescribeNetworkInterfaceAttribute : DescribeNetworkInterfaceAttribute
	#
	resolveDescribeNetworkInterfacesResult : resolveDescribeNetworkInterfacesResult

