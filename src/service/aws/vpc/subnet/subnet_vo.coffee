#*************************************************************************************
#* Filename     : subnet_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:23
#* Description  : vo define for subnet
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    subnet = {
        'subnetId'              :   ''
        'state'                 :   ''
        'vpcId'                 :   ''
        'cidrBlock'             :   ''
        'availableIpAddressCount'           :   ''
        'availabilityZone'      :   ''
        'defaultForAz'          :   ''
        'mapPublicIpOnLaunch'   :   ''
        'tagSet'                :   []
    }

    'component'     :   {
        'type'  :   'AWS.VPC.Subnet',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'SubnetId'  :   '',
            'State'     :   '',
            'VpcId'     :   '',
            'CidrBlock' :   '',
            'AvailableIpAddressCount'   :   '',
            'AvailabilityZone'      :   ''
        }
    }

    #public
    subnet : subnet
