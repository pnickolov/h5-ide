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

define [ 'MC', 'keypair_parser', 'result_vo' ], ( MC, keypair_parser, result_vo ) ->

    URL = '/aws/ec2/keypair/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "keypair." + api_name + " callback is null"
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
            console.log "keypair." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def CreateKeyPair(self, username, session_id, region_name, key_name):
    CreateKeyPair = ( src, username, session_id, region_name, key_name, callback ) ->
        send_request "CreateKeyPair", src, [ username, session_id, region_name, key_name ], keypair_parser.parserCreateKeyPairReturn, callback
        true

    #def DeleteKeyPair(self, username, session_id, region_name, key_name):
    DeleteKeyPair = ( src, username, session_id, region_name, key_name, callback ) ->
        send_request "DeleteKeyPair", src, [ username, session_id, region_name, key_name ], keypair_parser.parserDeleteKeyPairReturn, callback
        true

    #def ImportKeyPair(self, username, session_id, region_name, key_name, key_data):
    ImportKeyPair = ( src, username, session_id, region_name, key_name, key_data, callback ) ->
        send_request "ImportKeyPair", src, [ username, session_id, region_name, key_name, key_data ], keypair_parser.parserImportKeyPairReturn, callback
        true

    #def DescribeKeyPairs(self, username, session_id, region_name, key_names=None, filters=None):
    DescribeKeyPairs = ( src, username, session_id, region_name, key_names=null, filters=null, callback ) ->
        send_request "DescribeKeyPairs", src, [ username, session_id, region_name, key_names, filters ], keypair_parser.parserDescribeKeyPairsReturn, callback
        true

    #def upload(self, username, session_id, region_name, key_name, key_data):
    upload = ( src, username, session_id, region_name, key_name, key_data, callback ) ->
        send_request "upload", src, [ username, session_id, region_name, key_name, key_data ], keypair_parser.parserUploadReturn, callback
        true

    #def download(self, username, session_id, region_name, key_name):
    download = ( src, username, session_id, region_name, key_name, callback ) ->
        send_request "download", src, [ username, session_id, region_name, key_name ], keypair_parser.parserDownloadReturn, callback
        true

    #def remove(self, username, session_id, region_name, key_name):
    remove = ( src, username, session_id, region_name, key_name, callback ) ->
        send_request "remove", src, [ username, session_id, region_name, key_name ], keypair_parser.parserRemoveReturn, callback
        true

    #def list(self, username, session_id, region_name):
    list = ( src, username, session_id, region_name, callback ) ->
        send_request "list", src, [ username, session_id, region_name ], keypair_parser.parserListReturn, callback
        true


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

