#*************************************************************************************
#* Filename     : reservedinstance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:23
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/rds/reservedinstance/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "reservedinstance." + api_name + " callback is null"
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
			console.log "reservedinstance." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for DescribeReservedDBInstances return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeReservedDBInstancesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeReservedDBInstances return)
	parserDescribeReservedDBInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeReservedDBInstancesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeReservedDBInstancesReturn


	#///////////////// Parser for DescribeReservedDBInstancesOfferings return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeReservedDBInstancesOfferingsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeReservedDBInstancesOfferings return)
	parserDescribeReservedDBInstancesOfferingsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeReservedDBInstancesOfferingsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeReservedDBInstancesOfferingsReturn


	#############################################################

	#def DescribeReservedDBInstances(self, username, session_id, region_name,
	DescribeReservedDBInstances = ( src, username, session_id, callback ) ->
		send_request "DescribeReservedDBInstances", src, [ username, session_id ], parserDescribeReservedDBInstancesReturn, callback
		true

	#def DescribeReservedDBInstancesOfferings(self, username, session_id, region_name,
	DescribeReservedDBInstancesOfferings = ( src, username, session_id, callback ) ->
		send_request "DescribeReservedDBInstancesOfferings", src, [ username, session_id ], parserDescribeReservedDBInstancesOfferingsReturn, callback
		true


	#############################################################
	#public
	DescribeReservedDBInstances  : DescribeReservedDBInstances
	DescribeReservedDBInstancesOfferings : DescribeReservedDBInstancesOfferings

