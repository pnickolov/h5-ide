#*************************************************************************************
#* Filename     : ami_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:07
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'ami_service'], ( Backbone, ami_service ) ->

    AMIModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #CreateImage api (define function)
        CreateImage : ( src, username, session_id, region_name, instance_id, ami_name, ami_desc=null, no_reboot=false, bd_mappings=null ) ->

            me = this

            src.model = me

            ami_service.CreateImage src, username, session_id, region_name, instance_id, ami_name, ami_desc, no_reboot, bd_mappings, ( aws_result ) ->

                if !aws_result.is_error
                #CreateImage succeed

                    ami_info = aws_result.resolved_data

                    #set vo


                else
                #CreateImage failed

                    console.log 'ami.CreateImage failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_AMI_CREATE_IMAGE_RETURN', aws_result


        #RegisterImage api (define function)
        RegisterImage : ( src, username, session_id, region_name, ami_name=null, ami_desc=null ) ->

            me = this

            src.model = me

            ami_service.RegisterImage src, username, session_id, region_name, ami_name, ami_desc, ( aws_result ) ->

                if !aws_result.is_error
                #RegisterImage succeed

                    ami_info = aws_result.resolved_data

                    #set vo


                else
                #RegisterImage failed

                    console.log 'ami.RegisterImage failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_AMI_REGISTER_IMAGE_RETURN', aws_result


        #DeregisterImage api (define function)
        DeregisterImage : ( src, username, session_id, region_name, ami_id ) ->

            me = this

            src.model = me

            ami_service.DeregisterImage src, username, session_id, region_name, ami_id, ( aws_result ) ->

                if !aws_result.is_error
                #DeregisterImage succeed

                    ami_info = aws_result.resolved_data

                    #set vo


                else
                #DeregisterImage failed

                    console.log 'ami.DeregisterImage failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_AMI_DEREGISTER_IMAGE_RETURN', aws_result


        #ModifyImageAttribute api (define function)
        ModifyImageAttribute : ( src, username, session_id ) ->

            me = this

            src.model = me

            ami_service.ModifyImageAttribute src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #ModifyImageAttribute succeed

                    ami_info = aws_result.resolved_data

                    #set vo


                else
                #ModifyImageAttribute failed

                    console.log 'ami.ModifyImageAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_AMI_MODIFY_IMAGE_ATTR_RETURN', aws_result


        #ResetImageAttribute api (define function)
        ResetImageAttribute : ( src, username, session_id, region_name, ami_id, attribute_name='launchPermission' ) ->

            me = this

            src.model = me

            ami_service.ResetImageAttribute src, username, session_id, region_name, ami_id, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #ResetImageAttribute succeed

                    ami_info = aws_result.resolved_data

                    #set vo


                else
                #ResetImageAttribute failed

                    console.log 'ami.ResetImageAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_AMI_RESET_IMAGE_ATTR_RETURN', aws_result


        #DescribeImageAttribute api (define function)
        DescribeImageAttribute : ( src, username, session_id, region_name, ami_id, attribute_name ) ->

            me = this

            src.model = me

            ami_service.DescribeImageAttribute src, username, session_id, region_name, ami_id, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeImageAttribute succeed

                    ami_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeImageAttribute failed

                    console.log 'ami.DescribeImageAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_AMI_DESC_IMAGE_ATTR_RETURN', aws_result


        #DescribeImages api (define function)
        DescribeImages : ( src, username, session_id, region_name, ami_ids=null, owners=null, executable_by=null, filters=null ) ->

            me = this

            src.model = me

            ami_service.DescribeImages src, username, session_id, region_name, ami_ids, owners, executable_by, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeImages succeed

                    ami_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeImages failed

                    console.log 'ami.DescribeImages failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_AMI_DESC_IMAGES_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    ami_model = new AMIModel()

    #public (exposes methods)
    ami_model

