#*************************************************************************************
#* Filename     : eni_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:55
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'eni_service', 'base_model' ], ( Backbone, _, eni_service, base_model ) ->

    ENIModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeNetworkInterfaces api (define function)
        DescribeNetworkInterfaces : ( src, username, session_id, region_name, eni_ids=null, filters=null ) ->

            me = this

            src.model = me

            eni_service.DescribeNetworkInterfaces src, username, session_id, region_name, eni_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeNetworkInterfaces succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_ENI_DESC_NET_IFS_RETURN', aws_result

                else
                #DescribeNetworkInterfaces failed

                    console.log 'eni.DescribeNetworkInterfaces failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeNetworkInterfaceAttribute api (define function)
        DescribeNetworkInterfaceAttribute : ( src, username, session_id, region_name, eni_id, attribute ) ->

            me = this

            src.model = me

            eni_service.DescribeNetworkInterfaceAttribute src, username, session_id, region_name, eni_id, attribute, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeNetworkInterfaceAttribute succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_ENI_DESC_NET_IF_ATTR_RETURN', aws_result

                else
                #DescribeNetworkInterfaceAttribute failed

                    console.log 'eni.DescribeNetworkInterfaceAttribute failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    eni_model = new ENIModel()

    #public (exposes methods)
    eni_model

