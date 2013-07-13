#*************************************************************************************
#* Filename     : rds_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:22
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/rds/rds/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "rds." + api_name + " callback is null"
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
			console.log "rds." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for DescribeDBEngineVersions return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeDBEngineVersionsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeDBEngineVersions return)
	parserDescribeDBEngineVersionsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeDBEngineVersionsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeDBEngineVersionsReturn


	#///////////////// Parser for DescribeOrderableDBInstanceOptions return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeOrderableDBInstanceOptionsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeOrderableDBInstanceOptions return)
	parserDescribeOrderableDBInstanceOptionsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeOrderableDBInstanceOptionsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeOrderableDBInstanceOptionsReturn


	#///////////////// Parser for DescribeEngineDefaultParameters return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeEngineDefaultParametersResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeEngineDefaultParameters return)
	parserDescribeEngineDefaultParametersReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeEngineDefaultParametersResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeEngineDefaultParametersReturn


	#///////////////// Parser for DescribeEvents return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeEventsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeEvents return)
	parserDescribeEventsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeEventsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeEventsReturn


	#############################################################

	#def DescribeDBEngineVersions(self, username, session_id, region_name,
	DescribeDBEngineVersions = ( src, username, callback ) ->
		send_request "DescribeDBEngineVersions", src, [ username ], parserDescribeDBEngineVersionsReturn, callback
		true

	#def DescribeOrderableDBInstanceOptions(self, username, session_id, region_name,
	DescribeOrderableDBInstanceOptions = ( src, username, callback ) ->
		send_request "DescribeOrderableDBInstanceOptions", src, [ username ], parserDescribeOrderableDBInstanceOptionsReturn, callback
		true

	#def DescribeEngineDefaultParameters(self, username, session_id, region_name, pg_family, marker=None, max_records=None):
	DescribeEngineDefaultParameters = ( src, username, session_id, region_name, pg_family, marker=null, max_records=null, callback ) ->
		send_request "DescribeEngineDefaultParameters", src, [ username, session_id, region_name, pg_family, marker, max_records ], parserDescribeEngineDefaultParametersReturn, callback
		true

	#def DescribeEvents(self, username, session_id, region_name,
	DescribeEvents = ( src, username, session_id, callback ) ->
		send_request "DescribeEvents", src, [ username, session_id ], parserDescribeEventsReturn, callback
		true


	#############################################################
	#public
	DescribeDBEngineVersions     : DescribeDBEngineVersions
	DescribeOrderableDBInstanceOptions : DescribeOrderableDBInstanceOptions
	DescribeEngineDefaultParameters : DescribeEngineDefaultParameters
	DescribeEvents               : DescribeEvents

