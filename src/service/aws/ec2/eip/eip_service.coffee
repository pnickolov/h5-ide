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

define [ 'MC', 'eip_parser', 'result_vo' ], ( MC, eip_parser, result_vo ) ->

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

    #def AllocateAddress(self, username, session_id, region_name, domain=None):
    AllocateAddress = ( src, username, session_id, region_name, domain=null, callback ) ->
        send_request "AllocateAddress", src, [ username, session_id, region_name, domain ], eip_parser.parserAllocateAddressReturn, callback
        true

    #def ReleaseAddress(self, username, session_id, region_name, ip=None, allocation_id=None):
    ReleaseAddress = ( src, username, session_id, region_name, ip=null, allocation_id=null, callback ) ->
        send_request "ReleaseAddress", src, [ username, session_id, region_name, ip, allocation_id ], eip_parser.parserReleaseAddressReturn, callback
        true

    #def AssociateAddress(self, username, session_id, region_name,
    AssociateAddress = ( src, username, callback ) ->
        send_request "AssociateAddress", src, [ username ], eip_parser.parserAssociateAddressReturn, callback
        true

    #def DisassociateAddress(self, username, session_id, region_name, ip=None, association_id=None):
    DisassociateAddress = ( src, username, session_id, region_name, ip=null, association_id=null, callback ) ->
        send_request "DisassociateAddress", src, [ username, session_id, region_name, ip, association_id ], eip_parser.parserDisassociateAddressReturn, callback
        true

    #def DescribeAddresses(self, username, session_id, region_name, ips=None, allocation_ids=None, filters=None):
    DescribeAddresses = ( src, username, session_id, region_name, ips=null, allocation_ids=null, filters=null, callback ) ->
        send_request "DescribeAddresses", src, [ username, session_id, region_name, ips, allocation_ids, filters ], eip_parser.parserDescribeAddressesReturn, callback
        true


    #############################################################
    #public
    AllocateAddress              : AllocateAddress
    ReleaseAddress               : ReleaseAddress
    AssociateAddress             : AssociateAddress
    DisassociateAddress          : DisassociateAddress
    DescribeAddresses            : DescribeAddresses

