#*************************************************************************************
#* Filename     : subnet_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:18
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'subnet_service'], ( Backbone, subnet_service) ->

    SubnetModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeSubnets api (define function)
        DescribeSubnets : ( src, username, session_id, region_name, subnet_ids=null, filters=null ) ->

            me = this

            src.model = me

            subnet_service.DescribeSubnets src, username, session_id, region_name, subnet_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeSubnets succeed

                    subnet_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeSubnets failed

                    console.log 'subnet.DescribeSubnets failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'VPC_SNET_DESC_SUBNETS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    subnet_model = new SubnetModel()

    #public (exposes methods)
    subnet_model

