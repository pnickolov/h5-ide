#*************************************************************************************
#* Filename     : securitygroup_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:14
#* Description  : vo define for securitygroup
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    sg = {
        'ownerId'                   :   ''
        'groupId'                   :   ''
        'groupName'                 :   ''
        'groupDescription'          :   ''
        'vpcId'                     :   ''
        'ipPermissions'             :   []
        'ipPermissionsEgress'       :   []
        'tagSet'                    :   []
    }


    component   =   {
        'UID'   :   {
            'type'  :   'AWS.EC2.SecurityGroup',
            'name'  :   '',
            'uid'   :   '',
            'resource'  :{
                'OwnerId'   :   '',
                'GroupId'   :   '',
                'GroupName' :   '',
                'GroupDescription'  :   '',
                'VpcId'     :   '',
                'IpPermissions' :
                    [
                        {
                            'IpProtocol':   '',
                            'FromPort'  :   '',
                            'ToPort'    :   '',
                            'Groups'    :   [{
                                'UserId'    :   '',
                                'GroupId'   :   '',
                                'GroupName' :   ''
                                
                            }],
                            'IpRanges'  :   ''
                        }
                    ]
                'IpPermissionsEgress'   :
                    [
                        {
                            'IpProtocol':   '',
                            'FromPort'  :   '',
                            'ToPort'    :   '',
                            'Groups'    :   [{
                                'UserId'    :   '',
                                'GroupId'   :   '',
                                'GroupName' :   ''
                                
                            }],
                            'IpRanges'  :   ''
                        }
                    ]
                
                
            }
        
        }

    }
    #public
    #TO-DO

