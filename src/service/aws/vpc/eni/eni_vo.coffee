#*************************************************************************************
#* Filename     : eni_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : vo define for eni
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    eni = {
        'networkInterfaceId'        :   ''
        'subnetId'                  :   ''
        'vpcId'                     :   ''
        'availabilityZone'          :   ''
        'description'               :   ''
        'ownerId'                   :   ''
        'requesterId'               :   ''
        'requesterManaged'          :   ''
        'status'                    :   ''
        'macAddress'                :   ''
        'privateIpAddress'          :   ''
        'privateDnsName'            :   ''
        'sourceDestCheck'           :   ''
        'groupSet'                  :   []
        'attachment'                :   []
        'association'               :   []
        'tagSet'                    :   []
        'privateIpAddressesSet'     :   []

    }

    eni_attr = {
        'NetworkInterfaceId'        :   ''
        'Attribute'                 :   ''
    }

    component   :   {
        'type'  :   'AWS.VPC.NetworkInterface',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'NetworkInterfaceId'    :   '',
            'SubnetId'              :   '',
            'VpcId'                 :   '',
            'AvailabilityZone'      :   '',
            'Description'           :   '',
            'OwnerId'               :   '',
            'RequestId'             :   '',
            'RequestManaged'        :   '',
            'Status'                :   '',
            'PrivateIpAddress'      :   '',
            'PrivateDnsName'        :   '',
            'SourceDestCheck'       :   '',
            'MacAddress'            :   '',
            'SecondPriIpCount'      :   '',
            'GroupSet'              :   [
                {
                    'GroupId'   :   '',
                    'GroupName' :   ''
                }
            ],
            'Attachment'            :   {
                'AttachmentId'      :   '',
                'InstanceId'        :   '',
                'DeviceIndex'       :   '0',
                'AttachTime'        :   ''
            },
            'Association'           :   {
                'AttachmentId'      :   '',
                'InstanceId'        :   '',
                'PublicIp'          :   '',
                'IpOwnerId'         :   ''
            },
            'PrivateIpAddressSet'   :   [
                {
                    'PrivateIpAddress'  :   '',
                    'PrivateDnsName'    :   '',
                    'Primary'           :   ''
                }
                'Association'       :   {
                    'PublicIp'          :   '',
                    'PublicDnsName'     :   '',
                    'InstanceId'        :   '',
                    'IpOwnerId'         :   '',
                    'AssociationID'     :   '',
                    'AllocationID'      :   ''
                }
            ]
        }
    }

    #public

    eni : eni
    eni_attr : eni_attr