#*************************************************************************************
#* Filename     : vpngateway_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:24
#* Description  : vo define for vpngateway
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    vpn_gateway = {
        'vpnGatewayId'          :   ''
        'state'                 :   ''
        'type'                  :   ''
        'availabilityZone'      :   ''
        'attachments'           :   []
        'tagSet'                :   []
    }

    component       =   {
        'type'  :   'AWS.VPC.VPNGateway',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'VpnGatewayId'  :   '',
            'State'         :   '',
            'Type'          :   '',
            'AvailabilityZone'  :   '',
            'Attachments'   :   [
                {
                    'VpcId'     :   '',
                    'State'     :   ''
                }
            ]
        }
    }

    #public
    vpn_gateway : vpn_gateway

