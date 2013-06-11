#*************************************************************************************
#* Filename     : eip_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:10
#* Description  : vo define for eip
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    eip = {
        'publicIp'              :   ''
        'allocationId'          :   ''
        'domain'                :   ''
        'instanceId'            :   ''
        'associationId'         :   ''
        'networkInterfaceId'    :   ''
        'networkInterfaceOwnerId':  ''
    }

    component   =   {
        'UID'   :   {
            'type'  :   'AWS.EC2.EIP',
            'name'  :   '',
            'uid'   :   '',
            'resource'  :   {
                'PublicIp'      :   '',
                'AllocationId'  :   '',
                'Domain'        :   '',
                'InstanceId'    :   '',
                'AssociationId' :   '',
                'NetworkInterfaceId'    :   '',
                'NetworkInterfaceOwnerId'  : '',
                'AllowReassociation'    :   '',
                'PrivateIpAddress'  :   '',
                
            }
        }
    }
    #public
    #TO-DO

