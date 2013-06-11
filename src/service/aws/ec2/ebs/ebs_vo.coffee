#*************************************************************************************
#* Filename     : ebs_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:07
#* Description  : vo define for ebs
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    volume = {
        'volumeId'                  :   ''
        'size'                      :   ''
        'snapshotId'                :   ''
        'availabilityZone'          :   ''
        'status'                    :   ''
        'createTime'                :   ''
        'attachmentSet'             :   []
        'tagSet'                    :   []
        'volumeType'                :   ''
        'iops'                      :   ''
    }

    snapshot = {
        'snapshotId'                :   ''
        'volumeId'                  :   ''
        'status'                    :   ''
        'startTime'                 :   ''
        'progress'                  :   ''
        'ownerId'                   :   ''
        'volumeSize'                :   ''
        'description'               :   ''
        'ownerAlias'                :   ''
        'tagSet'                    :   ''
    }

    component = {

        'UID'   :   {
            'type'  :   'AWS.EC2.EBS.Volume',
            'name'  :   '',
            'uid'   :   '',
            'resource': {
                'VolumeId'  :   '',
                'Size'      :   '',
                'SnapshotId':   '',
                'AvailabilityZone'  :   '',
                'Status'    :   '',
                'CreateTime':   '',
                'VolumeType':   '',
                'Iops'      :   '',
                'AttachmentSet' :   {
                    'VolumeId'  :   '',
                    'InstanceId':   '',
                    'Device'    :   '',
                    'Status'    :   '',
                    'AttachTime':   '',
                    'DeleteOnTermination'   :   '',
                },
                'TagSet'    :["UID1","UID2"]
            
            }
        
        }

    }
    #public
    #TO-DO

