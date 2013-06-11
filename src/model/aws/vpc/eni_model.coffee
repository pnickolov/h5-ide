#*************************************************************************************
#* Filename     : eni_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:17
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'eni_service', 'eni_vo'], ( Backbone, eni_service, eni_vo ) ->

    ENIModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : eni_vo.eni
        }

        ###### api ######
        #DescribeNetworkInterfaces api (define function)
        DescribeNetworkInterfaces : ( src, username, session_id, region_name, eni_ids=null, filters=null ) ->

            me = this

            src.model = me

            eni_service.DescribeNetworkInterfaces src, username, session_id, region_name, eni_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeNetworkInterfaces succeed

                    eni_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeNetworkInterfaces failed

                    console.log 'eni.DescribeNetworkInterfaces failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_ENI_DESC_NET_IFS_RETURN', aws_result


        #DescribeNetworkInterfaceAttribute api (define function)
        DescribeNetworkInterfaceAttribute : ( src, username, session_id, region_name, eni_id, attribute ) ->

            me = this

            src.model = me

            eni_service.DescribeNetworkInterfaceAttribute src, username, session_id, region_name, eni_id, attribute, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeNetworkInterfaceAttribute succeed

                    eni_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeNetworkInterfaceAttribute failed

                    console.log 'eni.DescribeNetworkInterfaceAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_ENI_DESC_NET_IF_ATTR_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    eni_model = new ENIModel()

    #public (exposes methods)
    eni_model

