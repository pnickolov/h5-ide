#*************************************************************************************
#* Filename     : ec2_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:15
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/ec2/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "ec2." + api_name + " callback is null"
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
			console.log "ec2." + api_name + " error:" + error.toString()


		true
	# end of send_request


	#///////////////// Parser for CreateTags return  /////////////////
	#private (parser CreateTags return)
	parserCreateTagsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserCreateTagsReturn


	#///////////////// Parser for DeleteTags return  /////////////////
	#private (parser DeleteTags return)
	parserDeleteTagsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDeleteTagsReturn


	#///////////////// Parser for DescribeTags return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeTagsResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeTagsResponse.tagSet

	#private (parser DescribeTags return)
	parserDescribeTagsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeTagsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeTagsReturn


	#///////////////// Parser for DescribeRegions return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeRegionsResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeRegionsResponse.regionInfo

	#private (parser DescribeRegions return)
	parserDescribeRegionsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeRegionsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeRegionsReturn


	#///////////////// Parser for DescribeAvailabilityZones return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAvailabilityZonesResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeAvailabilityZonesResponse.availabilityZoneInfo

	#private (parser DescribeAvailabilityZones return)
	parserDescribeAvailabilityZonesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAvailabilityZonesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAvailabilityZonesReturn


	#############################################################

	#def CreateTags(self, username, session_id, region_name, resource_ids, tags):
	CreateTags = ( src, username, session_id, region_name, resource_ids, tags, callback ) ->
		send_request "CreateTags", src, [ username, session_id, region_name, resource_ids, tags ], parserCreateTagsReturn, callback
		true

	#def DeleteTags(self, username, session_id, region_name, resource_ids, tags):
	DeleteTags = ( src, username, session_id, region_name, resource_ids, tags, callback ) ->
		send_request "DeleteTags", src, [ username, session_id, region_name, resource_ids, tags ], parserDeleteTagsReturn, callback
		true

	#def DescribeTags(self, username, session_id, region_name, filters=None):
	DescribeTags = ( src, username, session_id, region_name, filters=null, callback ) ->
		send_request "DescribeTags", src, [ username, session_id, region_name, filters ], parserDescribeTagsReturn, callback
		true

	#def DescribeRegions(self, username, session_id, region_names=None, filters=None):
	DescribeRegions = ( src, username, session_id, region_names=null, filters=null, callback ) ->
		send_request "DescribeRegions", src, [ username, session_id, region_names, filters ], parserDescribeRegionsReturn, callback
		true

	#def DescribeAvailabilityZones(self, username, session_id, region_name, zone_names=None, filters=None):
	DescribeAvailabilityZones = ( src, username, session_id, region_name, zone_names=null, filters=null, callback ) ->
		send_request "DescribeAvailabilityZones", src, [ username, session_id, region_name, zone_names, filters ], parserDescribeAvailabilityZonesReturn, callback
		true


	#############################################################
	#public
	CreateTags                   : CreateTags
	DeleteTags                   : DeleteTags
	DescribeTags                 : DescribeTags
	DescribeRegions              : DescribeRegions
	DescribeAvailabilityZones    : DescribeAvailabilityZones
	#
	resolveDescribeAvailabilityZonesResult : resolveDescribeAvailabilityZonesResult

