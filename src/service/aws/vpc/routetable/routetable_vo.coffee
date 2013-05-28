#*************************************************************************************
#* Filename     : routetable_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:23
#* Description  : vo define for routetable
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    routetable = {
        'routeTableId'          :   ''
        'vpcId'                 :   ''
        'routeSet'              :   []
        'associationSet'        :   []
        'propagatingVgwSet'     :   []
        'tagSet'                :   []
    }

    component       =   {
        'type'  :   'AWS.VPC.RouteTable',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'RouteTableId'      :   '',
            'VpcId'             :   '',
            'RouteSet'          :   [
                {
                    'DestinationCidrBlock'      :   '',
                    'GatewayId'                 :   '',
                    'InstanceId'                :   '',
                    'InstanceOwnerId'           :   '',
                    'NetworkInterfaceId'        :   '',
                    'State'                     :   '',
                    'Origin'                    :   ''
                }
            ],
            'AssociationSet'    :   [
                {
                    'RouteTableAssociationId'       :   '',
                    'RouteTableId'                  :   '',
                    'SubnetId'                      :   '',
                    'Main'                          :   ''
                }
            ],
            'PropagatingVgwSet' :   [
                {
                    'GatewayId' :   ''
                }
            ]
        }
    }
    
    #public
    routetable : routetable

