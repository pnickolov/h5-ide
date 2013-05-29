#*************************************************************************************
#* Filename     : ami_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:06
#* Description  : vo define for ami
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    ami = {
        'imageId'           :   ''
        'imageLocation'     :   ''
        'imageState'        :   ''
        'imageOwnerId'      :   ''
        'isPublic'          :   ''
        'productCodes'      :   []
        'architecture'      :   ''
        'imageType'         :   ''
        'kernelId'          :   ''
        'ramdiskId'         :   ''
        'platform'          :   ''
        'stateReason'       :   ''
        'imageOwnerAlias'   :   ''
        'name'              :   ''
        'description'       :   ''
        'rootDeviceType'    :   ''
        'rootDeviceName'    :   ''
        'blockDeviceMapping':   []
        'virtualizationType':   ''
        'tagSet'            :   []
        'hypervisor'        :   ''
    }

    #public
    #TO-DO

