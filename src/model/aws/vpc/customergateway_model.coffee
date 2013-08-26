#*************************************************************************************
#* Filename     : customergateway_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:55
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'customergateway_service', 'base_model' ], ( Backbone, _, customergateway_service, base_model ) ->

    CustomerGatewayModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeCustomerGateways api (define function)
        DescribeCustomerGateways : ( src, username, session_id, region_name, gw_ids=null, filters=null ) ->

            me = this

            src.model = me

            customergateway_service.DescribeCustomerGateways src, username, session_id, region_name, gw_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeCustomerGateways succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_CGW_DESC_CUST_GWS_RETURN', aws_result

                else
                #DescribeCustomerGateways failed

                    console.log 'customergateway.DescribeCustomerGateways failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    customergateway_model = new CustomerGatewayModel()

    #public (exposes methods)
    customergateway_model

