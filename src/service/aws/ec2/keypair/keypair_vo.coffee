#*************************************************************************************
#* Filename     : keypair_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:13
#* Description  : vo define for keypair
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    keypair = {
        'keyName'           :   ''
        'keyFingerprint'    :   ''
    }

    component   =   {
        'UID'   :   {
            'type'  :   'AWS.EC2.KeyPair',
            'name'  :   '',
            'uid'   :   '',
            'resource'  :   {
                'KeyName'   :   '',
                'KeyFingerprint'    :   ''
            }
        }
    }

    #public
    #TO-DO

