#*************************************************************************************
#* Filename     : securitygroup_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:16
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'securitygroup_service'], ( Backbone, securitygroup_service) ->

    SecurityGroupModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeDBSecurityGroups api (define function)
        DescribeDBSecurityGroups : ( src, username, session_id, region_name, sg_name=null, marker=null, max_records=null ) ->

            me = this

            src.model = me

            securitygroup_service.DescribeDBSecurityGroups src, username, session_id, region_name, sg_name, marker, max_records, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBSecurityGroups succeed

                    securitygroup_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeDBSecurityGroups failed

                    console.log 'securitygroup.DescribeDBSecurityGroups failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_SG_DESC_DB_SGS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    securitygroup_model = new SecurityGroupModel()

    #public (exposes methods)
    securitygroup_model

