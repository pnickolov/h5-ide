#*************************************************************************************
#* Filename     : internetgateway_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:18
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'internetgateway_service'], ( Backbone, internetgateway_service) ->

    InternetGatewayModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeInternetGateways api (define function)
        DescribeInternetGateways : ( src, username, session_id, region_name, gw_ids=null, filters=null ) ->

            me = this

            src.model = me

            internetgateway_service.DescribeInternetGateways src, username, session_id, region_name, gw_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInternetGateways succeed

                    internetgateway_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeInternetGateways failed

                    console.log 'internetgateway.DescribeInternetGateways failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'VPC_IGW_DESC_INET_GWS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    internetgateway_model = new InternetGatewayModel()

    #public (exposes methods)
    internetgateway_model

