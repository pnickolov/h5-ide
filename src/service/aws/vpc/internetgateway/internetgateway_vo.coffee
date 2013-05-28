#*************************************************************************************
#* Filename     : internetgateway_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:23
#* Description  : vo define for internetgateway
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    igw = {
        'internetGatewayId'             :   ''
        'attachmentSet'                 :   []
        'tagSet'                        :   []
    }

    component   =   {
        'UID'   :   {
            'type'  :   'AWS.VPC.InternetGateway',
            'name'  :   '',
            'uid'   :   '',
            'resource'  :   {
                'InternetGatewayId'     :   '',
                'AttachmentSet'         :   [
                    {
                        'VpcId'     :   '',
                        'State'     :   ''
                    }
                ]
            }
        }
    }

    #public

    igw : igw
