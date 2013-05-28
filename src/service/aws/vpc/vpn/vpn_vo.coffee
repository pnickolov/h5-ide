#*************************************************************************************
#* Filename     : vpn_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:24
#* Description  : vo define for vpn
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    vpn = {
        'vpnConnectionId'           :   ''
        'state'                     :   ''
        'customerGatewayConfiguration'  :   ''
        'type'                      :   ''
        'customerGatewayId'         :   ''
        'vpnGatewayId'              :   ''
        'tagSet'                    :   []
        'vgwTelemetry'              :   []
        'options'                   :   []
        'routes'                    :   []
    }

    component       =   {
        'type'  :   'AWS.VPC.VPNConnection',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'VpnConnectionId'   :   '',
            'State'             :   '',
            'CustomerGatewayConfiguration'  :   '',
            'Type'              :   '',
            'CustomerGatewayId' :   '',
            'VpnGatewayId'      :   '',
            'VgwTelemetry'      :   {
                'OutsideIpAddress'  :   '',
                'Status'        :   '',
                'LastStatusChange'  :   '',
                'StatusMessage' :   '',
                'AcceptRouteCount'  :   ''
            },
            'Options'   :   {
                'StaticRoutesOnly'  :   ''
            },
            'Routes'    :   [
                {
                    'DestinationCidrBlock'  :   '',
                    'Source'    :   '',
                    'State'     :   ''
                }
            ]
        }
    }

    #public
    vpn : vpn
