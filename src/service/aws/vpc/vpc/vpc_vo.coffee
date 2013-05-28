#*************************************************************************************
#* Filename     : vpc_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:23
#* Description  : vo define for vpc
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    vpc = {
        'vpcId'             :   ''
        'state'             :   ''
        'cidrBlock'         :   ''
        'dhcpOptionsId'     :   ''
        'tagSet'            :   []
        'instanceTenancy'   :   ''
        'isDefault'         :   ''
    }

    component   =   {
        'type'  :   'AWS.VPC.VPC',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'VpcId'         :   '',
            'State'         :   '',
            'CidrBlock'     :   '',
            'DhcpOptionsId' :   '',
            'InstanceTenancy'   :   '',
            'IsDefault'     :   '',
            'EnableDnsSupport'  :   '',
            'EnableDnsHostnames':   ''
        }
    }
    
    #public
    vpc : vpc

