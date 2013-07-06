#*************************************************************************************
#* Filename     : aws_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:12
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
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

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
            console.log "aws." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def quickstart(self, username, session_id, region_name):
    quickstart = ( src, username, session_id, region_name, callback ) ->
        send_request "quickstart", src, [ username, session_id, region_name ], aws_parser.parserQuickstartReturn, callback
        true

    #def public(self, username, session_id, region_name):
    Public = ( src, username, session_id, region_name, filters, callback ) ->
        send_request "public", src, [ username, session_id, region_name, filters ], aws_parser.parserPublicReturn, callback
        true

    #def info(self, username, session_id, region_name):
    info = ( src, username, session_id, region_name, callback ) ->
        send_request "info", src, [ username, session_id, region_name ], aws_parser.parserInfoReturn, callback
        true

    #def resource(self, username, session_id, region_name=None, resources=None):
    resource = ( src, username, session_id, region_name=null, resources=null, callback ) ->
        send_request "resource", src, [ username, session_id, region_name, resources ], aws_parser.parserResourceReturn, callback
        true

    #def price(self, username, session_id):
    price = ( src, username, session_id, callback ) ->
        send_request "price", src, [ username, session_id ], aws_parser.parserPriceReturn, callback
        true

    #def status(self, username, session_id):
    status = ( src, username, session_id, callback ) ->
        send_request "status", src, [ username, session_id ], aws_parser.parserStatusReturn, callback
        true


    #############################################################
    #public
    quickstart                   : quickstart
    Public                       : Public
    info                         : info
    resource                     : resource
    price                        : price
    status                       : status

