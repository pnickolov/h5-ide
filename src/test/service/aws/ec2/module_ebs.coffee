#*************************************************************************************
#* Filename     : ebs_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:07
#* Description  : qunit test module for ebs_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'ebs_service'], ( MC, $, test_util, session_service, ebs_service ) ->

    #test user
    username    = test_util.username
    password    = test_util.password

    #session info
    session_id  = ""
    usercode    = ""
    region_name = ""

    can_test    = false

    test "Check test user", () ->
        if username == "" or password == ""
            ok false, "please set the username and password first(/test/service/test_util), then try again"
        else
            ok true, "passwd"
            can_test = true

    if !can_test
        return false


    ################################################
    #session login
    ################################################
    module "Module Session"

    asyncTest "session.login", () ->
        session_service.login username, password, ( forge_result ) ->
            if !forge_result.is_error
            #login succeed
                session_info = forge_result.resolved_data
                session_id   = session_info.session_id
                usercode     = session_info.usercode
                region_name  = session_info.region_name
                ok true, "login succeed" + "( usercode : " + usercode + " , region_name : " + region_name + " , session_id : " + session_id + ")"
                username = usercode
                start()
            else
            #login failed
                ok false, "login failed, error is " + forge_result.error_message + ", cancel the follow-up test!"
                start()



    ################################################
    #aws/ec2 test
    ################################################
    module "Module aws/ec2 - ebs"
    #-----------------------------------------------
    #Test DescribeVolumes()
    #-----------------------------------------------
    asyncTest "/aws/ec2 ebs.DescribeVolumes()", () ->
        
        volume_ids = null
        filters = null

        ebs_service.DescribeVolumes username, session_id, region_name, volume_ids, filters, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeVolumes succeed
                data = aws_result.resolved_data
                ok true, "DescribeVolumes() succeed"
                start()
            else
            #DescribeVolumes failed
                ok false, "DescribeVolumes() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeVolumeAttribute()
    #-----------------------------------------------
    asyncTest "/aws/ec2 ebs.DescribeVolumeAttribute()", () ->
        
        volume_id = null
        attribute_name = null

        ebs_service.DescribeVolumeAttribute username, session_id, region_name, volume_id, attribute_name, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeVolumeAttribute succeed
                data = aws_result.resolved_data
                ok true, "DescribeVolumeAttribute() succeed"
                start()
            else
            #DescribeVolumeAttribute failed
                ok false, "DescribeVolumeAttribute() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeVolumeStatus()
    #-----------------------------------------------
    asyncTest "/aws/ec2 ebs.DescribeVolumeStatus()", () ->
        
        volume_ids = null
        filters = null
        max_result = null
        next_token = null

        ebs_service.DescribeVolumeStatus username, session_id, region_name, volume_ids, filters, max_result, next_token, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeVolumeStatus succeed
                data = aws_result.resolved_data
                ok true, "DescribeVolumeStatus() succeed"
                start()
            else
            #DescribeVolumeStatus failed
                ok false, "DescribeVolumeStatus() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeSnapshots()
    #-----------------------------------------------
    asyncTest "/aws/ec2 ebs.DescribeSnapshots()", () ->
        
        snapshot_ids = null
        owners = null
        restorable_by = null
        filters = null

        ebs_service.DescribeSnapshots username, session_id, region_name, snapshot_ids, owners, restorable_by, filters, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeSnapshots succeed
                data = aws_result.resolved_data
                ok true, "DescribeSnapshots() succeed"
                start()
            else
            #DescribeSnapshots failed
                ok false, "DescribeSnapshots() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeSnapshotAttribute()
    #-----------------------------------------------
    asyncTest "/aws/ec2 ebs.DescribeSnapshotAttribute()", () ->
        
        snapshot_id = null
        attribute_name = null

        ebs_service.DescribeSnapshotAttribute username, session_id, region_name, snapshot_id, attribute_name, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeSnapshotAttribute succeed
                data = aws_result.resolved_data
                ok true, "DescribeSnapshotAttribute() succeed"
                start()
            else
            #DescribeSnapshotAttribute failed
                ok false, "DescribeSnapshotAttribute() failed" + aws_result.error_message
                start()

