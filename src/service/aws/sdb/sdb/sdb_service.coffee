#*************************************************************************************
#* Filename     : sdb_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:21
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'sdb_parser', 'result_vo' ], ( MC, sdb_parser, result_vo ) ->

    URL = '/aws/sdb/sdb/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

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
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "sdb." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DomainMetadata(self, username, session_id, region_name, doamin_name):
    DomainMetadata = ( username, session_id, region_name, doamin_name, callback ) ->
        send_request "DomainMetadata", [ username, session_id, region_name, doamin_name ], sdb_parser.parserDomainMetadataReturn, callback
        true

    #def GetAttributes(self, username, session_id, region_name, domain_name, item_name, attribute_name=None, consistent_read=None):
    GetAttributes = ( username, session_id, region_name, domain_name, item_name, attribute_name=null, consistent_read=null, callback ) ->
        send_request "GetAttributes", [ username, session_id, region_name, domain_name, item_name, attribute_name, consistent_read ], sdb_parser.parserGetAttributesReturn, callback
        true

    #def ListDomains(self, username, session_id, region_name, max_domains=None, next_token=None):
    ListDomains = ( username, session_id, region_name, max_domains=null, next_token=null, callback ) ->
        send_request "ListDomains", [ username, session_id, region_name, max_domains, next_token ], sdb_parser.parserListDomainsReturn, callback
        true


    #############################################################
    #public
    DomainMetadata               : DomainMetadata
    GetAttributes                : GetAttributes
    ListDomains                  : ListDomains

