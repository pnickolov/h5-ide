#*************************************************************************************
#* Filename     : placementgroup_service.coffee
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

	URL = '/aws/ec2/placementgroup/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "placementgroup." + api_name + " callback is null"
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
			console.log "placementgroup." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for CreatePlacementGroup return  /////////////////
	#private (parser CreatePlacementGroup return)
	parserCreatePlacementGroupReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserCreatePlacementGroupReturn


	#///////////////// Parser for DeletePlacementGroup return  /////////////////
	#private (parser DeletePlacementGroup return)
	parserDeletePlacementGroupReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDeletePlacementGroupReturn


	#///////////////// Parser for DescribePlacementGroups return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribePlacementGroupsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribePlacementGroups return)
	parserDescribePlacementGroupsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribePlacementGroupsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribePlacementGroupsReturn


	#############################################################

	#def CreatePlacementGroup(self, username, session_id, region_name, group_name, strategy='cluster'):
	CreatePlacementGroup = ( src, username, session_id, region_name, group_name, strategy='cluster', callback ) ->
		send_request "CreatePlacementGroup", src, [ username, session_id, region_name, group_name, strategy ], parserCreatePlacementGroupReturn, callback
		true

	#def DeletePlacementGroup(self, username, session_id, region_name, group_name):
	DeletePlacementGroup = ( src, username, session_id, region_name, group_name, callback ) ->
		send_request "DeletePlacementGroup", src, [ username, session_id, region_name, group_name ], parserDeletePlacementGroupReturn, callback
		true

	#def DescribePlacementGroups(self, username, session_id, region_name, group_names=None, filters=None):
	DescribePlacementGroups = ( src, username, session_id, region_name, group_names=null, filters=null, callback ) ->
		send_request "DescribePlacementGroups", src, [ username, session_id, region_name, group_names, filters ], parserDescribePlacementGroupsReturn, callback
		true


	#############################################################
	#public
	CreatePlacementGroup         : CreatePlacementGroup
	DeletePlacementGroup         : DeletePlacementGroup
	DescribePlacementGroups      : DescribePlacementGroups

