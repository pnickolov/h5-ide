#*************************************************************************************
#* Filename     : acl_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:21
#* Description  : vo define for acl
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    acl = {
        "networkAclId"  :   ""
        "vpcId"         :   ""
        "default"       :   ""
        "entrySet"      :   []
        "associationSet":   []
        "tagSet"        :   []
    }

    component       =   {
        'type'                  :   'AWS.VPC.NetworkAcl',
        'name'                  :   '',
        'uid'                   :   '',
        'resource'              :   {
            'NetworkAclId'      :   '',
            'VpcId'             :   '',
            'Default'           :   '',
            'EntrySet'          :   [
                {
                    'RuleNumber'    :   '',
                    'Protocol'      :   '',
                    'RuleAction'    :   '',
                    'Egress'        :   '',
                    'CidrBlock'     :   '',
                    'IcmpTypeCode'  :   {
                        'Code'      :   '',
                        'Type'      :   ''
                    },
                    'PortRange'     :   {
                        'From'      :   '',
                        'To'        :   ''
                    }
                }
            ],
            'AssociationSet'        :   [
                {
                    'NetworkAclAssociationId'   :   '',
                    'NetworkAclId'              :   '',
                    'SubnetId'                  :   ''
                }
            ]
        }
    }
    
    #public
    acl : acl
