#*************************************************************************************
#* Filename     : sdb_service.coffee
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

	URL = '/aws/sdb/sdb/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "sdb." + api_name + " callback is null"
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
			console.log "sdb." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for DomainMetadata return  /////////////////
	#private (parser DomainMetadata return)
	parserDomainMetadataReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDomainMetadataReturn


	#///////////////// Parser for GetAttributes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveGetAttributesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser GetAttributes return)
	parserGetAttributesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveGetAttributesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserGetAttributesReturn


	#///////////////// Parser for ListDomains return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveListDomainsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser ListDomains return)
	parserListDomainsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveListDomainsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserListDomainsReturn


	#############################################################

	#def DomainMetadata(self, username, session_id, region_name, doamin_name):
	DomainMetadata = ( src, username, session_id, region_name, doamin_name, callback ) ->
		send_request "DomainMetadata", src, [ username, session_id, region_name, doamin_name ], parserDomainMetadataReturn, callback
		true

	#def GetAttributes(self, username, session_id, region_name, domain_name, item_name, attribute_name=None, consistent_read=None):
	GetAttributes = ( src, username, session_id, region_name, domain_name, item_name, attribute_name=null, consistent_read=null, callback ) ->
		send_request "GetAttributes", src, [ username, session_id, region_name, domain_name, item_name, attribute_name, consistent_read ], parserGetAttributesReturn, callback
		true

	#def ListDomains(self, username, session_id, region_name, max_domains=None, next_token=None):
	ListDomains = ( src, username, session_id, region_name, max_domains=null, next_token=null, callback ) ->
		send_request "ListDomains", src, [ username, session_id, region_name, max_domains, next_token ], parserListDomainsReturn, callback
		true


	#############################################################
	#public
	DomainMetadata               : DomainMetadata
	GetAttributes                : GetAttributes
	ListDomains                  : ListDomains

