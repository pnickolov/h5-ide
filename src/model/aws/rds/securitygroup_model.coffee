#*************************************************************************************
#* Filename     : securitygroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:54
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
        #DescribeDBSecurityGroups api (define function)
        DescribeDBSecurityGroups : ( src, username, session_id, region_name, sg_name=null, marker=null, max_records=null ) ->

            me = this

            src.model = me

            securitygroup_service.DescribeDBSecurityGroups src, username, session_id, region_name, sg_name, marker, max_records, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBSecurityGroups succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_SG_DESC_DB_SGS_RETURN', aws_result

                else
                #DescribeDBSecurityGroups failed

                    console.log 'securitygroup.DescribeDBSecurityGroups failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    securitygroup_model = new SecurityGroupModel()

    #public (exposes methods)
    securitygroup_model

