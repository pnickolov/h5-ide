#*************************************************************************************
#* Filename     : ebs_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:08
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'ebs_service', 'ebs_vo'], ( Backbone, ebs_service, ebs_vo ) ->

    EBSModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : ebs_vo.ebs
        }

        ###### api ######
        #CreateVolume api (define function)
        CreateVolume : ( src, username, session_id, region_name, zone_name, snapshot_id=null, volume_size=null, volume_type=null, iops=null ) ->

            me = this

            src.model = me

            ebs_service.CreateVolume src, username, session_id, region_name, zone_name, snapshot_id, volume_size, volume_type, iops, ( aws_result ) ->

                if !aws_result.is_error
                #CreateVolume succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #CreateVolume failed

                    console.log 'ebs.CreateVolume failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_CREATE_VOL_RETURN', aws_result


        #DeleteVolume api (define function)
        DeleteVolume : ( src, username, session_id, region_name, volume_id ) ->

            me = this

            src.model = me

            ebs_service.DeleteVolume src, username, session_id, region_name, volume_id, ( aws_result ) ->

                if !aws_result.is_error
                #DeleteVolume succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DeleteVolume failed

                    console.log 'ebs.DeleteVolume failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DELETE_VOL_RETURN', aws_result


        #AttachVolume api (define function)
        AttachVolume : ( src, username, session_id, region_name, volume_id, instance_id, device ) ->

            me = this

            src.model = me

            ebs_service.AttachVolume src, username, session_id, region_name, volume_id, instance_id, device, ( aws_result ) ->

                if !aws_result.is_error
                #AttachVolume succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #AttachVolume failed

                    console.log 'ebs.AttachVolume failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_ATTACH_VOL_RETURN', aws_result


        #DetachVolume api (define function)
        DetachVolume : ( src, username, session_id, region_name, volume_id, instance_id=null, device=null, force=false ) ->

            me = this

            src.model = me

            ebs_service.DetachVolume src, username, session_id, region_name, volume_id, instance_id, device, force, ( aws_result ) ->

                if !aws_result.is_error
                #DetachVolume succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DetachVolume failed

                    console.log 'ebs.DetachVolume failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DETACH_VOL_RETURN', aws_result


        #DescribeVolumes api (define function)
        DescribeVolumes : ( src, username, session_id, region_name, volume_ids=null, filters=null ) ->

            me = this

            src.model = me

            ebs_service.DescribeVolumes src, username, session_id, region_name, volume_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVolumes succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVolumes failed

                    console.log 'ebs.DescribeVolumes failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DESC_VOLS_RETURN', aws_result


        #DescribeVolumeAttribute api (define function)
        DescribeVolumeAttribute : ( src, username, session_id, region_name, volume_id, attribute_name='autoEnableIO' ) ->

            me = this

            src.model = me

            ebs_service.DescribeVolumeAttribute src, username, session_id, region_name, volume_id, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVolumeAttribute succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVolumeAttribute failed

                    console.log 'ebs.DescribeVolumeAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DESC_VOL_ATTR_RETURN', aws_result


        #DescribeVolumeStatus api (define function)
        DescribeVolumeStatus : ( src, username, session_id, region_name, volume_ids, filters=null, max_result=null, next_token=null ) ->

            me = this

            src.model = me

            ebs_service.DescribeVolumeStatus src, username, session_id, region_name, volume_ids, filters, max_result, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVolumeStatus succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVolumeStatus failed

                    console.log 'ebs.DescribeVolumeStatus failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DESC_VOL_STATUS_RETURN', aws_result


        #ModifyVolumeAttribute api (define function)
        ModifyVolumeAttribute : ( src, username, session_id, region_name, volume_id, auto_enable_IO=false ) ->

            me = this

            src.model = me

            ebs_service.ModifyVolumeAttribute src, username, session_id, region_name, volume_id, auto_enable_IO, ( aws_result ) ->

                if !aws_result.is_error
                #ModifyVolumeAttribute succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #ModifyVolumeAttribute failed

                    console.log 'ebs.ModifyVolumeAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_MODIFY_VOL_ATTR_RETURN', aws_result


        #EnableVolumeIO api (define function)
        EnableVolumeIO : ( src, username, session_id, region_name, volume_id ) ->

            me = this

            src.model = me

            ebs_service.EnableVolumeIO src, username, session_id, region_name, volume_id, ( aws_result ) ->

                if !aws_result.is_error
                #EnableVolumeIO succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #EnableVolumeIO failed

                    console.log 'ebs.EnableVolumeIO failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_ENABLE_VOL_I_O_RETURN', aws_result


        #CreateSnapshot api (define function)
        CreateSnapshot : ( src, username, session_id, region_name, volume_id, description=null ) ->

            me = this

            src.model = me

            ebs_service.CreateSnapshot src, username, session_id, region_name, volume_id, description, ( aws_result ) ->

                if !aws_result.is_error
                #CreateSnapshot succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #CreateSnapshot failed

                    console.log 'ebs.CreateSnapshot failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_CREATE_SS_RETURN', aws_result


        #DeleteSnapshot api (define function)
        DeleteSnapshot : ( src, username, session_id, region_name, snapshot_id ) ->

            me = this

            src.model = me

            ebs_service.DeleteSnapshot src, username, session_id, region_name, snapshot_id, ( aws_result ) ->

                if !aws_result.is_error
                #DeleteSnapshot succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DeleteSnapshot failed

                    console.log 'ebs.DeleteSnapshot failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DELETE_SS_RETURN', aws_result


        #ModifySnapshotAttribute api (define function)
        ModifySnapshotAttribute : ( src, username, session_id, region_name, snapshot_id, user_ids, group_names ) ->

            me = this

            src.model = me

            ebs_service.ModifySnapshotAttribute src, username, session_id, region_name, snapshot_id, user_ids, group_names, ( aws_result ) ->

                if !aws_result.is_error
                #ModifySnapshotAttribute succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #ModifySnapshotAttribute failed

                    console.log 'ebs.ModifySnapshotAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_MODIFY_SS_ATTR_RETURN', aws_result


        #ResetSnapshotAttribute api (define function)
        ResetSnapshotAttribute : ( src, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission' ) ->

            me = this

            src.model = me

            ebs_service.ResetSnapshotAttribute src, username, session_id, region_name, snapshot_id, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #ResetSnapshotAttribute succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #ResetSnapshotAttribute failed

                    console.log 'ebs.ResetSnapshotAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_RESET_SS_ATTR_RETURN', aws_result


        #DescribeSnapshots api (define function)
        DescribeSnapshots : ( src, username, session_id, region_name, snapshot_ids=null, owners=null, restorable_by=null, filters=null ) ->

            me = this

            src.model = me

            ebs_service.DescribeSnapshots src, username, session_id, region_name, snapshot_ids, owners, restorable_by, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeSnapshots succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeSnapshots failed

                    console.log 'ebs.DescribeSnapshots failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DESC_SSS_RETURN', aws_result


        #DescribeSnapshotAttribute api (define function)
        DescribeSnapshotAttribute : ( src, username, session_id, region_name, snapshot_id, attribute_name='createVolumePermission' ) ->

            me = this

            src.model = me

            ebs_service.DescribeSnapshotAttribute src, username, session_id, region_name, snapshot_id, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeSnapshotAttribute succeed

                    ebs_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeSnapshotAttribute failed

                    console.log 'ebs.DescribeSnapshotAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_EBS_DESC_SS_ATTR_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    ebs_model = new EBSModel()

    #public (exposes methods)
    ebs_model

