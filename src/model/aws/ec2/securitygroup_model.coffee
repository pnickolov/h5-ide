#*************************************************************************************
#* Filename     : securitygroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:06
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'securitygroup_service', 'securitygroup_vo'], ( Backbone, securitygroup_service, securitygroup_vo ) ->

    SecurityGroupModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : securitygroup_vo.securitygroup
        }

        ###### api ######
        #CreateSecurityGroup api (define function)
        CreateSecurityGroup : ( src, username, session_id, region_name, group_name, group_desc, vpc_id=null ) ->

            me = this

            src.model = me

            securitygroup_service.CreateSecurityGroup src, username, session_id, region_name, group_name, group_desc, vpc_id=null, ( aws_result ) ->

                if !aws_result.is_error
                #CreateSecurityGroup succeed

                    securitygroup_info = aws_result.resolved_data

                    #set vo


                else
                #CreateSecurityGroup failed

                    console.log 'securitygroup.CreateSecurityGroup failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_SG_CREATE_SG_RETURN', aws_result


        #DeleteSecurityGroup api (define function)
        DeleteSecurityGroup : ( src, username, session_id, region_name, group_name=null, group_id=null ) ->

            me = this

            src.model = me

            securitygroup_service.DeleteSecurityGroup src, username, session_id, region_name, group_name=null, group_id=null, ( aws_result ) ->

                if !aws_result.is_error
                #DeleteSecurityGroup succeed

                    securitygroup_info = aws_result.resolved_data

                    #set vo


                else
                #DeleteSecurityGroup failed

                    console.log 'securitygroup.DeleteSecurityGroup failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_SG_DELETE_SG_RETURN', aws_result


        #AuthorizeSecurityGroupIngress api (define function)
        AuthorizeSecurityGroupIngress : ( src, username, session_id ) ->

            me = this

            src.model = me

            securitygroup_service.AuthorizeSecurityGroupIngress src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #AuthorizeSecurityGroupIngress succeed

                    securitygroup_info = aws_result.resolved_data

                    #set vo


                else
                #AuthorizeSecurityGroupIngress failed

                    console.log 'securitygroup.AuthorizeSecurityGroupIngress failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_SG_AUTH_SG_INGRESS_RETURN', aws_result


        #RevokeSecurityGroupIngress api (define function)
        RevokeSecurityGroupIngress : ( src, username, session_id ) ->

            me = this

            src.model = me

            securitygroup_service.RevokeSecurityGroupIngress src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #RevokeSecurityGroupIngress succeed

                    securitygroup_info = aws_result.resolved_data

                    #set vo


                else
                #RevokeSecurityGroupIngress failed

                    console.log 'securitygroup.RevokeSecurityGroupIngress failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_SG_REVOKE_SG_INGRESS_RETURN', aws_result


        #DescribeSecurityGroups api (define function)
        DescribeSecurityGroups : ( src, username, session_id, region_name, group_names=null, group_ids=null, filters=null ) ->

            me = this

            src.model = me

            securitygroup_service.DescribeSecurityGroups src, username, session_id, region_name, group_names=null, group_ids=null, filters=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeSecurityGroups succeed

                    securitygroup_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeSecurityGroups failed

                    console.log 'securitygroup.DescribeSecurityGroups failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'EC2_SG_DESC_SGS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    securitygroup_model = new SecurityGroupModel()

    #public (exposes methods)
    securitygroup_model

