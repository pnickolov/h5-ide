#*************************************************************************************
#* Filename     : keypair_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:18
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/ec2/keypair/'

	#private
	send_request = result_vo.genSendRequest URL
	# end of send_request

	#///////////////// Parser for CreateKeyPair return  /////////////////
	#private (parser CreateKeyPair return)
	parserCreateKeyPairReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveCreateKeyPairsResult result

			aws_result.resolved_data = resolved_data

		#3.return vo
		aws_result

	# end of parserCreateKeyPairReturn


	#///////////////// Parser for DeleteKeyPair return  /////////////////
	#private (parser DeleteKeyPair return)
	parserDeleteKeyPairReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserDeleteKeyPairReturn


	#///////////////// Parser for ImportKeyPair return  /////////////////
	#private (parser ImportKeyPair return)
	parserImportKeyPairReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveImportKeyPairsResult result

			aws_result.resolved_data = resolved_data

		#3.return vo
		aws_result

	# end of parserImportKeyPairReturn


	#///////////////// Parser for DescribeKeyPairs return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveCreateKeyPairsResult = ( result ) ->
		#resolve result

		#return vo
		result_set = ($.xml2json ($.parseXML result[1])).CreateKeyPairResponse

		return result_set

	resolveImportKeyPairsResult = ( result ) ->
		#resolve result

		#return vo
		result_set = ($.xml2json ($.parseXML result[1])).ImportKeyPairResponse

		return result_set

	resolveDescribeKeyPairsResult = ( result ) ->
		#resolve result

		#return vo
		result_set = ($.xml2json ($.parseXML result[1])).DescribeKeyPairsResponse.keySet

		if result_set?.item?

			return result_set.item

		else

			return null


	#private (parser DescribeKeyPairs return)
	parserDescribeKeyPairsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeKeyPairsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeKeyPairsReturn


	#///////////////// Parser for upload return  /////////////////
	#private (parser upload return)
	parserUploadReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processForgeReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserUploadReturn


	#///////////////// Parser for download return  /////////////////
	#private (parser download return)
	parserDownloadReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processForgeReturnHandler result, return_code, param
		aws_result.resolved_data = result

		#2.return vo
		aws_result

	# end of parserDownloadReturn


	#///////////////// Parser for remove return  /////////////////
	#private (parser remove return)
	parserRemoveReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserRemoveReturn


	#///////////////// Parser for list return  /////////////////
	#private (parser list return)
	parserListReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserListReturn


	#############################################################

	#def CreateKeyPair(self, username, session_id, region_name, key_name):
	CreateKeyPair = ( src, username, session_id, region_name, key_name, callback ) ->
		send_request "CreateKeyPair", src, [ username, session_id, region_name, key_name ], parserCreateKeyPairReturn, callback

	#def DeleteKeyPair(self, username, session_id, region_name, key_name):
	DeleteKeyPair = ( src, username, session_id, region_name, key_name, callback ) ->
		send_request "DeleteKeyPair", src, [ username, session_id, region_name, key_name ], parserDeleteKeyPairReturn, callback

	#def ImportKeyPair(self, username, session_id, region_name, key_name, key_data):
	ImportKeyPair = ( src, username, session_id, region_name, key_name, key_data, callback ) ->
		send_request "ImportKeyPair", src, [ username, session_id, region_name, key_name, key_data ], parserImportKeyPairReturn, callback

	#def DescribeKeyPairs(self, username, session_id, region_name, key_names=None, filters=None):
	DescribeKeyPairs = ( src, username, session_id, region_name, key_names=null, filters=null, callback ) ->
		send_request "DescribeKeyPairs", src, [ username, session_id, region_name, key_names, filters ], parserDescribeKeyPairsReturn, callback

	#def upload(self, username, session_id, region_name, key_name, key_data):
	upload = ( src, username, session_id, region_name, key_name, key_data, callback ) ->
		send_request "upload", src, [ username, session_id, region_name, key_name, key_data ], parserUploadReturn, callback

	#def download(self, username, session_id, region_name, key_name):
	download = ( src, username, session_id, region_name, key_name, callback ) ->
		send_request "download", src, [ username, session_id, region_name, key_name ], parserDownloadReturn, callback

	#def remove(self, username, session_id, region_name, key_name):
	remove = ( src, username, session_id, region_name, key_name, callback ) ->
		send_request "remove", src, [ username, session_id, region_name, key_name ], parserRemoveReturn, callback

	#def list(self, username, session_id, region_name):
	list = ( src, username, session_id, region_name, callback ) ->
		send_request "list", src, [ username, session_id, region_name ], parserListReturn, callback


	#############################################################
	#public
	CreateKeyPair                : CreateKeyPair
	DeleteKeyPair                : DeleteKeyPair
	ImportKeyPair                : ImportKeyPair
	DescribeKeyPairs             : DescribeKeyPairs
	upload                       : upload
	download                     : download
	remove                       : remove
	list                         : list
	#
	resolveDescribeKeyPairsResult : resolveDescribeKeyPairsResult

