#*************************************************************************************
#* Filename     : ami_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:13
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/ec2/ami/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "ami." + api_name + " callback is null"
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
			console.log "ami." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for CreateImage return  /////////////////
	#private (parser CreateImage return)
	parserCreateImageReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserCreateImageReturn


	#///////////////// Parser for RegisterImage return  /////////////////
	#private (parser RegisterImage return)
	parserRegisterImageReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserRegisterImageReturn


	#///////////////// Parser for DeregisterImage return  /////////////////
	#private (parser DeregisterImage return)
	parserDeregisterImageReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDeregisterImageReturn


	#///////////////// Parser for ModifyImageAttribute return  /////////////////
	#private (parser ModifyImageAttribute return)
	parserModifyImageAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserModifyImageAttributeReturn


	#///////////////// Parser for ResetImageAttribute return  /////////////////
	#private (parser ResetImageAttribute return)
	parserResetImageAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserResetImageAttributeReturn


	#///////////////// Parser for DescribeImageAttribute return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeImageAttributeResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeImageAttributeResponse

	#private (parser DescribeImageAttribute return)
	parserDescribeImageAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeImageAttributeResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeImageAttributeReturn


	#///////////////// Parser for DescribeImages return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeImagesResult = ( result ) ->
		#resolve result

		#return vo
		result_set = ($.xml2json ($.parseXML result[1])).DescribeImagesResponse.imagesSet

		if result_set?.item?

			return result_set.item

		else

			return null

	#private (parser DescribeImages return)
	parserDescribeImagesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeImagesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeImagesReturn


	#############################################################

	#def CreateImage(self, username, session_id, region_name, instance_id, ami_name, ami_desc=None, no_reboot=False, bd_mappings=None):
	CreateImage = ( src, username, session_id, region_name, instance_id, ami_name, ami_desc=null, no_reboot=false, bd_mappings=null, callback ) ->
		send_request "CreateImage", src, [ username, session_id, region_name, instance_id, ami_name, ami_desc, no_reboot, bd_mappings ], parserCreateImageReturn, callback
		true

	#def RegisterImage(self, username, session_id, region_name, ami_name=None, ami_desc=None, location=None,
	RegisterImage = ( src, username, session_id, region_name, ami_name=null, ami_desc=null, callback ) ->
		send_request "RegisterImage", src, [ username, session_id, region_name, ami_name, ami_desc ], parserRegisterImageReturn, callback
		true

	#def DeregisterImage(self, username, session_id, region_name, ami_id):
	DeregisterImage = ( src, username, session_id, region_name, ami_id, callback ) ->
		send_request "DeregisterImage", src, [ username, session_id, region_name, ami_id ], parserDeregisterImageReturn, callback
		true

	#def ModifyImageAttribute(self, username, session_id, region_name, ami_id,
	ModifyImageAttribute = ( src, username, session_id, callback ) ->
		send_request "ModifyImageAttribute", src, [ username, session_id ], parserModifyImageAttributeReturn, callback
		true

	#def ResetImageAttribute(self, username, session_id, region_name, ami_id, attribute_name='launchPermission'):
	ResetImageAttribute = ( src, username, session_id, region_name, ami_id, attribute_name='launchPermission', callback ) ->
		send_request "ResetImageAttribute", src, [ username, session_id, region_name, ami_id, attribute_name ], parserResetImageAttributeReturn, callback
		true

	#def DescribeImageAttribute(self, username, session_id, region_name, ami_id, attribute_name):
	DescribeImageAttribute = ( src, username, session_id, region_name, ami_id, attribute_name, callback ) ->
		send_request "DescribeImageAttribute", src, [ username, session_id, region_name, ami_id, attribute_name ], parserDescribeImageAttributeReturn, callback
		true

	#def DescribeImages(self, username, session_id, region_name, ami_ids=None, owners=None, executable_by=None, filters=None):
	DescribeImages = ( src, username, session_id, region_name, ami_ids=null, owners=null, executable_by=null, filters=null, callback ) ->
		send_request "DescribeImages", src, [ username, session_id, region_name, ami_ids, owners, executable_by, filters ], parserDescribeImagesReturn, callback
		true


	#############################################################
	#public
	CreateImage                  : CreateImage
	RegisterImage                : RegisterImage
	DeregisterImage              : DeregisterImage
	ModifyImageAttribute         : ModifyImageAttribute
	ResetImageAttribute          : ResetImageAttribute
	DescribeImageAttribute       : DescribeImageAttribute
	DescribeImages               : DescribeImages
	#
	resolveDescribeImagesResult  : resolveDescribeImagesResult

