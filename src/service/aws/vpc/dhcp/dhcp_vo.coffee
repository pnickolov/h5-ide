#*************************************************************************************
#* Filename     : dhcp_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : vo define for dhcp
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    dhcp = {
        'dhcpOptionsId'             :   ''
        'dhcpConfigurationSet'      :   []
        'tagSet'                    :   []
    }

    component   =   {
        'type'  :   'AWS.VPC.DhcpOptions',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'DhcpOptionsId' :   '',
            'VpcId'         :   '',
            'DhcpConfigurationSet'  :   [
                {
                    'Key'   :   '',
                    'ValueSet'  :   [
                        {
                            'Value' :   ''
                        }
                    ]
                }
            ]
        }
    }
    #public
    dhcp : dhcp