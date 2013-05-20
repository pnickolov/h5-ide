require [ 'MC', 'jquery', 'session_service', 'instance_service'], ( MC, $, session_service, instance_service ) ->

    #test user
    username    = ""
    password    = ""

    #session info
    session_id  = ""
    usercode    = ""
    region_name = ""

    test "Check test user", () ->
        if username == "" or password == ""
            ok false, "please set the username and password first"


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
                start()
            else
            #login failed
                ok false, "login failed, error is " + forge_result.error_message + ", cancel the follow-up test!"
                start()

    #login failed then top test
    #if session_id == ""
        #to-do


    ################################################
    #AWS.EC2.Instance test
    ################################################
    module "Module AWS.EC2.Instance"

    #-----------------------------------------------
    #Test DescribeInstances()
    #-----------------------------------------------
    asyncTest "aws.ec2.instance.DescribeInstances", () ->
        console.log "DescribeInstances(" + usercode + "," + session_id + "," + region_name + ")"
        instance_service.DescribeInstances usercode, session_id, region_name, null, null, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeInstances succeed
                instanceList = aws_result.resolved_data
                ok true, "aws.ec2.instance.DescribeInstances() succeed"
                start()
            else
            #DescribeInstances failed
                ok false, "aws.ec2.instance.DescribeInstances() failed" + aws_result.error_message
                start()


