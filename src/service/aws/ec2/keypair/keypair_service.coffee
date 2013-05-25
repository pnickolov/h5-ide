#*************************************************************************************
#* Filename     : keypair_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:13
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
    send_request =  ( api_name, param_ary, parser, callback ) ->

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
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "keypair." + method + " error:" + error.toString()


        true
    # end of send_request

    #def CreateKeyPair(self, username, session_id, region_name, key_name):
    CreateKeyPair = ( username, session_id, region_name, key_name, callback ) ->
        send_request "CreateKeyPair", [ username, session_id, region_name, key_name ], keypair_parser.parserCreateKeyPairReturn, callback
        true

    #def DeleteKeyPair(self, username, session_id, region_name, key_name):
    DeleteKeyPair = ( username, session_id, region_name, key_name, callback ) ->
        send_request "DeleteKeyPair", [ username, session_id, region_name, key_name ], keypair_parser.parserDeleteKeyPairReturn, callback
        true

    #def ImportKeyPair(self, username, session_id, region_name, key_name, key_data):
    ImportKeyPair = ( username, session_id, region_name, key_name, key_data, callback ) ->
        send_request "ImportKeyPair", [ username, session_id, region_name, key_name, key_data ], keypair_parser.parserImportKeyPairReturn, callback
        true

    #def DescribeKeyPairs(self, username, session_id, region_name, key_names=None, filters=None):
    DescribeKeyPairs = ( username, session_id, region_name, key_names=null, filters=null, callback ) ->
        send_request "DescribeKeyPairs", [ username, session_id, region_name, key_names, filters ], keypair_parser.parserDescribeKeyPairsReturn, callback
        true

    #def upload(self, username, session_id, region_name, key_name, key_data):
    upload = ( username, session_id, region_name, key_name, key_data, callback ) ->
        send_request "upload", [ username, session_id, region_name, key_name, key_data ], keypair_parser.parserUploadReturn, callback
        true

    #def download(self, username, session_id, region_name, key_name):
    download = ( username, session_id, region_name, key_name, callback ) ->
        send_request "download", [ username, session_id, region_name, key_name ], keypair_parser.parserDownloadReturn, callback
        true

    #def remove(self, username, session_id, region_name, key_name):
    remove = ( username, session_id, region_name, key_name, callback ) ->
        send_request "remove", [ username, session_id, region_name, key_name ], keypair_parser.parserRemoveReturn, callback
        true

    #def list(self, username, session_id, region_name):
    list = ( username, session_id, region_name, callback ) ->
        send_request "list", [ username, session_id, region_name ], keypair_parser.parserListReturn, callback
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

