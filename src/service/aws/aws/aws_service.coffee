#*************************************************************************************
#* Filename     : aws_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:05
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'aws_parser', 'result_vo' ], ( MC, aws_parser, result_vo ) ->

    URL = '/aws/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "aws." + api_name + " callback is null"
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
            console.log "aws." + method + " error:" + error.toString()


        true
    # end of send_request

    #def quickstart(self, username, session_id, region_name):
    quickstart = ( username, session_id, region_name, callback ) ->
        send_request "quickstart", [ username, session_id, region_name ], aws_parser.parserQuickstartReturn, callback
        true

    #def public(self, username, session_id, region_name):
    Public = ( username, session_id, region_name, callback ) ->
        send_request "public", [ username, session_id, region_name ], aws_parser.parserPublicReturn, callback
        true

    #def info(self, username, session_id, region_name):
    info = ( username, session_id, region_name, callback ) ->
        send_request "info", [ username, session_id, region_name ], aws_parser.parserInfoReturn, callback
        true

    #def resource(self, username, session_id, region_name=None, resources=None):
    resource = ( username, session_id, region_name=null, resources=null, callback ) ->
        send_request "resource", [ username, session_id, region_name, resources ], aws_parser.parserResourceReturn, callback
        true

    #def price(self, username, session_id):
    price = ( username, session_id, callback ) ->
        send_request "price", [ username, session_id ], aws_parser.parserPriceReturn, callback
        true

    #def status(self, username, session_id):
    status = ( username, session_id, callback ) ->
        send_request "status", [ username, session_id ], aws_parser.parserStatusReturn, callback
        true


    #############################################################
    #public
    quickstart                   : quickstart
    Public                       : Public
    info                         : info
    resource                     : resource
    price                        : price
    status                       : status

