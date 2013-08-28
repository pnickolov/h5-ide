#*************************************************************************************
#* Filename     : securitygroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:50
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'securitygroup_service', 'base_model' ], ( Backbone, _, securitygroup_service, base_model ) ->

    SecurityGroupModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #CreateSecurityGroup api (define function)
        CreateSecurityGroup : ( src, username, session_id, region_name, group_name, group_desc, vpc_id=null ) ->

            me = this

            src.model = me

            securitygroup_service.CreateSecurityGroup src, username, session_id, region_name, group_name, group_desc, vpc_id, ( aws_result ) ->

                if !aws_result.is_error
                #CreateSecurityGroup succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_SG_CREATE_SG_RETURN', aws_result

                else
                #CreateSecurityGroup failed

                    console.log 'securitygroup.CreateSecurityGroup failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DeleteSecurityGroup api (define function)
        DeleteSecurityGroup : ( src, username, session_id, region_name, group_name=null, group_id=null ) ->

            me = this

            src.model = me

            securitygroup_service.DeleteSecurityGroup src, username, session_id, region_name, group_name, group_id, ( aws_result ) ->

                if !aws_result.is_error
                #DeleteSecurityGroup succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_SG_DELETE_SG_RETURN', aws_result

                else
                #DeleteSecurityGroup failed

                    console.log 'securitygroup.DeleteSecurityGroup failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #AuthorizeSecurityGroupIngress api (define function)
        AuthorizeSecurityGroupIngress : ( src, username, session_id ) ->

            me = this

            src.model = me

            securitygroup_service.AuthorizeSecurityGroupIngress src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #AuthorizeSecurityGroupIngress succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_SG_AUTH_SG_INGRESS_RETURN', aws_result

                else
                #AuthorizeSecurityGroupIngress failed

                    console.log 'securitygroup.AuthorizeSecurityGroupIngress failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #RevokeSecurityGroupIngress api (define function)
        RevokeSecurityGroupIngress : ( src, username, session_id ) ->

            me = this

            src.model = me

            securitygroup_service.RevokeSecurityGroupIngress src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #RevokeSecurityGroupIngress succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_SG_REVOKE_SG_INGRESS_RETURN', aws_result

                else
                #RevokeSecurityGroupIngress failed

                    console.log 'securitygroup.RevokeSecurityGroupIngress failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeSecurityGroups api (define function)
        DescribeSecurityGroups : ( src, username, session_id, region_name, group_names=null, group_ids=null, filters=null ) ->

            me = this

            src.model = me

            securitygroup_service.DescribeSecurityGroups src, username, session_id, region_name, group_names, group_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeSecurityGroups succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_SG_DESC_SGS_RETURN', aws_result

                else
                #DescribeSecurityGroups failed

                    console.log 'securitygroup.DescribeSecurityGroups failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    securitygroup_model = new SecurityGroupModel()

    #public (exposes methods)
    securitygroup_model

