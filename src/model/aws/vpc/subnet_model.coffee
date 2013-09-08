#*************************************************************************************
#* Filename     : subnet_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:56
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'subnet_service', 'base_model' ], ( Backbone, _, subnet_service, base_model ) ->

    SubnetModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeSubnets api (define function)
        DescribeSubnets : ( src, username, session_id, region_name, subnet_ids=null, filters=null ) ->

            me = this

            src.model = me

            subnet_service.DescribeSubnets src, username, session_id, region_name, subnet_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeSubnets succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_SNET_DESC_SUBNETS_RETURN', aws_result

                else
                #DescribeSubnets failed

                    console.log 'subnet.DescribeSubnets failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    subnet_model = new SubnetModel()

    #public (exposes methods)
    subnet_model

