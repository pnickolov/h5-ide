#*************************************************************************************
#* Filename     : acl_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:17
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'acl_service', 'acl_vo'], ( Backbone, acl_service, acl_vo ) ->

    ACLModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : acl_vo.acl
        }

        ###### api ######
        #DescribeNetworkAcls api (define function)
        DescribeNetworkAcls : ( src, username, session_id, region_name, acl_ids=null, filters=null ) ->

            me = this

            src.model = me

            acl_service.DescribeNetworkAcls src, username, session_id, region_name, acl_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeNetworkAcls succeed

                    acl_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeNetworkAcls failed

                    console.log 'acl.DescribeNetworkAcls failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_ACL_DESC_NET_ACLS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    acl_model = new ACLModel()

    #public (exposes methods)
    acl_model

