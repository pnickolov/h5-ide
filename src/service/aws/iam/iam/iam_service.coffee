#*************************************************************************************
#* Filename     : iam_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:20
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'iam_parser', 'result_vo' ], ( MC, iam_parser, result_vo ) ->

    URL = '/aws/iam/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "iam." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "iam." + method + " error:" + error.toString()


        true
    # end of send_request

    #def GetServerCertificate(self, username, session_id, region_name, servercer_name):
    GetServerCertificate = ( src, username, session_id, region_name, servercer_name, callback ) ->
        send_request "GetServerCertificate", src, [ username, session_id, region_name, servercer_name ], iam_parser.parserGetServerCertificateReturn, callback
        true

    #def ListServerCertificates(self, username, session_id, region_name, marker=None, max_items=None, path_prefix=None):
    ListServerCertificates = ( src, username, session_id, region_name, marker=null, max_items=null, path_prefix=null, callback ) ->
        send_request "ListServerCertificates", src, [ username, session_id, region_name, marker, max_items, path_prefix ], iam_parser.parserListServerCertificatesReturn, callback
        true


    #############################################################
    #public
    GetServerCertificate         : GetServerCertificate
    ListServerCertificates       : ListServerCertificates

