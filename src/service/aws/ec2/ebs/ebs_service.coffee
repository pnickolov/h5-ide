#*************************************************************************************
#* Filename     : ebs_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:14
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'ebs_parser', 'result_vo' ], ( MC, ebs_parser, result_vo ) ->

    URL = '/aws/ec2/ebs/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "ebs." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
                    aws_result = {}
                    aws_result = parser result, return_code, param_ary

                    callback aws_result

                error : ( result, return_code ) ->

                    aws_result = {}
                    aws_result.return_code      = return_code
                    aws_result.is_error         = true
                    aws_result.error_message    = result.toString()

                    callback aws_result
            }

        catch error
            console.log "ebs." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def CreateVolume(self, username, session_id, region_name, zone_name, snapshot_id=None, volume_size=None, volume_type=None, iops=None):
    CreateVolume = ( src, username, session_id, region_name, zone_name, snapshot_id=null, volume_size=null, volume_type=null, iops=null, callback ) ->
        send_request "CreateVolume", src, [ username, session_id, region_name, zone_name, snapshot_id, volume_size, volume_type, iops ], ebs_parser.parserCreateVolumeReturn, callback
        true

    #def DeleteVolume(self, username, session_id, region_name, volume_id):
    DeleteVolume = ( src, username, session_id, region_name, volume_id, callback ) ->
        send_request "DeleteVolume", src, [ username, session_id, region_name, volume_id ], ebs_parser.parserDeleteVolumeReturn, callback
        true

    #def AttachVolume(self, username, session_id, region_name, volume_id, instance_id, device):
    AttachVolume = ( src, username, session_id, region_name, volume_id, instance_id, device, callback ) ->
        send_request "AttachVolume", src, [ username, session_id, region_name, volume_id, instance_id, device ], ebs_parser.parserAttachVolumeReturn, callback
        true

    #def DetachVolume(self, username, session_id, region_name, volume_id, instance_id=None, device=None, force=False):
    DetachVolume = ( src, username, session_id, region_name, volume_id, instance_id=null, device=null, force=false, callback ) ->
        send_request "DetachVolume", src, [ username, session_id, region_name, volume_id, instance_id, device, force ], ebs_parser.parserDetachVolumeReturn, callback
        true

    #def DescribeVolumes(self, username, session_id, region_name, volume_ids=None, filters=None):
    DescribeVolumes = ( src, username, session_id, region_name, volume_ids=null, filters=null, callback ) ->
        send_request "DescribeVolumes", src, [ username, session_id, region_name, volume_ids, filters ], ebs_parser.parserDescribeVolumesReturn, callback
        true

    #def DescribeVolumeAttribute(self, username, session_id, region_name, volume_id, attribute_name='autoEnableIO'):
    DescribeVolumeAttribute = ( src, username, session_id, region_name, volume_id, attribute_name='autoEnableIO', callback ) ->
        send_request "DescribeVolumeAttribute", src, [ username, session_id, region_name, volume_id, attribute_name ], ebs_parser.parserDescribeVolumeAttributeReturn, callback
        true

    #def DescribeVolumeStatus(self, username, session_id, region_name, volume_ids, filters=None, max_result=None, next_token=None):
    DescribeVolumeStatus = ( src, username, session_id, region_name, volume_ids, filters=null, max_result=null, next_token=null, callback ) ->
        send_request "DescribeVolumeStatus", src, [ username, session_id, region_name, volume_ids, filters, max_result, next_token ], ebs_parser.parserDescribeVolumeStatusReturn, callback
        true

    #def ModifyVolumeAttribute(self, username, session_id, region_name, volume_id, auto_enable_IO=False):
    ModifyVolumeAttribute = ( src, username, session_id, region_name, volume_id, auto_enable_IO=false, callback ) ->
        send_request "ModifyVolumeAttribute", src, [ username, session_id, region_name, volume_id, auto_enable_IO ], ebs_parser.parserModifyVolumeAttributeReturn, callback
        true

    #def EnableVolumeIO(self, username, session_id, region_name, volume_id):
    EnableVolumeIO = ( src, username, session_id, region_name, volume_id, callback ) ->
        send_request "EnableVolumeIO", src, [ username, session_id, region_name, volume_id ], ebs_parser.parserEnableVolumeIOReturn, callback
        true

    #def CreateSnapshot(self, username, session_id, region_name, volume_id, description=None):
    CreateSnapshot = ( src, username, session_id, region_name, volume_id, description=null, callback ) ->
        send_request "CreateSnapshot", src, [ username, session_id, region_name, volume_id, description ], ebs_parser.parserCreateSnapshotReturn, callback
        true

    #def DeleteSnapshot(self, username, session_id, region_name, snapshot_id):
    DeleteSnapshot = ( src, username, session_id, region_name, snapshot_id, callback ) ->
        send_request "DeleteSnapshot", src, [ username, session_id, region_name, snapshot_id ], ebs_parser.parserDeleteSnapshotReturn, callback
        true

    #def ModifySnapshotAttribute(self, username, session_id, region_name, snapshot_id, user_ids, group_names):
    ModifySnapshotAttribute = ( src, username, session_id, region_name, snapshot_id, user_ids, group_names, callback ) ->
        send_request "ModifySnapshotAttribute", src, [ username, session_id, region_name, snapshot_id, user_ids, group_names ], ebs_parser.parserModifySnapshotAttributeReturn, callback
        true

    #def ResetSnapshotAttribute(self, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission'):
    ResetSnapshotAttribute = ( src, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission', callback ) ->
        send_request "ResetSnapshotAttribute", src, [ username, session_id, region_name, snapshot_id, attribute_name ], ebs_parser.parserResetSnapshotAttributeReturn, callback
        true

    #def DescribeSnapshots(self, username, session_id, region_name, snapshot_ids=None, owners=None, restorable_by=None, filters=None):
    DescribeSnapshots = ( src, username, session_id, region_name, snapshot_ids=null, owners=null, restorable_by=null, filters=null, callback ) ->
        send_request "DescribeSnapshots", src, [ username, session_id, region_name, snapshot_ids, owners, restorable_by, filters ], ebs_parser.parserDescribeSnapshotsReturn, callback
        true

    #def DescribeSnapshotAttribute(self, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission'):
    DescribeSnapshotAttribute = ( src, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission', callback ) ->
        send_request "DescribeSnapshotAttribute", src, [ username, session_id, region_name, snapshot_id, attribute_name ], ebs_parser.parserDescribeSnapshotAttributeReturn, callback
        true


    #############################################################
    #public
    CreateVolume                 : CreateVolume
    DeleteVolume                 : DeleteVolume
    AttachVolume                 : AttachVolume
    DetachVolume                 : DetachVolume
    DescribeVolumes              : DescribeVolumes
    DescribeVolumeAttribute      : DescribeVolumeAttribute
    DescribeVolumeStatus         : DescribeVolumeStatus
    ModifyVolumeAttribute        : ModifyVolumeAttribute
    EnableVolumeIO               : EnableVolumeIO
    CreateSnapshot               : CreateSnapshot
    DeleteSnapshot               : DeleteSnapshot
    ModifySnapshotAttribute      : ModifySnapshotAttribute
    ResetSnapshotAttribute       : ResetSnapshotAttribute
    DescribeSnapshots            : DescribeSnapshots
    DescribeSnapshotAttribute    : DescribeSnapshotAttribute

