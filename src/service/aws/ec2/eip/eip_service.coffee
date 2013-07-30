#*************************************************************************************
#* Filename     : eip_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:16
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/ec2/elasticip/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "eip." + api_name + " callback is null"
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
			console.log "eip." + api_name + " error:" + error.toString()


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

	#///////////////// Parser for AllocateAddress return  /////////////////
	#private (parser AllocateAddress return)
	parserAllocateAddressReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserAllocateAddressReturn


	#///////////////// Parser for ReleaseAddress return  /////////////////
	#private (parser ReleaseAddress return)
	parserReleaseAddressReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserReleaseAddressReturn


	#///////////////// Parser for AssociateAddress return  /////////////////
	#private (parser AssociateAddress return)
	parserAssociateAddressReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserAssociateAddressReturn


	#///////////////// Parser for DisassociateAddress return  /////////////////
	#private (parser DisassociateAddress return)
	parserDisassociateAddressReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDisassociateAddressReturn


	#///////////////// Parser for DescribeAddresses return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAddressesResult = ( result ) ->
		#resolve result
		#return vo
		result_set = ($.xml2json ($.parseXML result[1])).DescribeAddressesResponse.addressesSet

		result = resolvedObjectToArray result_set

		if result?.item?

			return result.item

		else

			return null

	#private (parser DescribeAddresses return)
	parserDescribeAddressesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAddressesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAddressesReturn


	#############################################################

	#def AllocateAddress(self, username, session_id, region_name, domain=None):
	AllocateAddress = ( src, username, session_id, region_name, domain=null, callback ) ->
		send_request "AllocateAddress", src, [ username, session_id, region_name, domain ], parserAllocateAddressReturn, callback
		true

	#def ReleaseAddress(self, username, session_id, region_name, ip=None, allocation_id=None):
	ReleaseAddress = ( src, username, session_id, region_name, ip=null, allocation_id=null, callback ) ->
		send_request "ReleaseAddress", src, [ username, session_id, region_name, ip, allocation_id ], parserReleaseAddressReturn, callback
		true

	#def AssociateAddress(self, username, session_id, region_name,
	AssociateAddress = ( src, username, callback ) ->
		send_request "AssociateAddress", src, [ username ], parserAssociateAddressReturn, callback
		true

	#def DisassociateAddress(self, username, session_id, region_name, ip=None, association_id=None):
	DisassociateAddress = ( src, username, session_id, region_name, ip=null, association_id=null, callback ) ->
		send_request "DisassociateAddress", src, [ username, session_id, region_name, ip, association_id ], parserDisassociateAddressReturn, callback
		true

	#def DescribeAddresses(self, username, session_id, region_name, ips=None, allocation_ids=None, filters=None):
	DescribeAddresses = ( src, username, session_id, region_name, ips=null, allocation_ids=null, filters=null, callback ) ->
		send_request "DescribeAddresses", src, [ username, session_id, region_name, ips, allocation_ids, filters ], parserDescribeAddressesReturn, callback
		true


	#############################################################
	#public
	AllocateAddress              : AllocateAddress
	ReleaseAddress               : ReleaseAddress
	AssociateAddress             : AssociateAddress
	DisassociateAddress          : DisassociateAddress
	DescribeAddresses            : DescribeAddresses
	#
	resolveDescribeAddressesResult : resolveDescribeAddressesResult

