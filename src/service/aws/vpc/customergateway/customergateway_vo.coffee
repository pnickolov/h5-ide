#*************************************************************************************
#* Filename     : customergateway_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : vo define for customergateway
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    cgw = {
        'customerGatewayId'     :   ''
        'state'                 :   ''
        'type'                  :   ''
        'ipAddress'             :   ''
        'bgpAsn'                :   ''
        'tagSet'                :   []
    }

    component   =   {
        'type'  :   'AWS.VPC.CustomerGateway',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'CustomerGatewayId' :   '',
            'State'             :   '',
            'Type'              :   '',
            'IpAddress'         :   '',
            'BgpAsn'            :   '',
        }
    }

    #public
    cgw : cgw