#*************************************************************************************
#* Filename     : vpc_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:56
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'vpc_service', 'base_model' ], ( Backbone, _, vpc_service, base_model ) ->

    VPCModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeVpcs api (define function)
        DescribeVpcs : ( src, username, session_id, region_name, vpc_ids=null, filters=null ) ->

            me = this

            src.model = me

            vpc_service.DescribeVpcs src, username, session_id, region_name, vpc_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVpcs succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_VPC_DESC_VPCS_RETURN', aws_result

                else
                #DescribeVpcs failed

                    console.log 'vpc.DescribeVpcs failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeAccountAttributes api (define function)
        DescribeAccountAttributes : ( src, username, session_id, region_name, attribute_name ) ->

            me = this

            src.model = me

            vpc_service.DescribeAccountAttributes src, username, session_id, region_name, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAccountAttributes succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', aws_result

                else
                #DescribeAccountAttributes failed

                    console.log 'vpc.DescribeAccountAttributes failed, error is ' + aws_result.error_message
                    #me.pub aws_result

                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', aws_result



        #DescribeVpcAttribute api (define function)
        DescribeVpcAttribute : ( src, username, session_id, region_name, vpc_id, attribute ) ->

            me = this

            src.model = me

            vpc_service.DescribeVpcAttribute src, username, session_id, region_name, vpc_id, attribute, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVpcAttribute succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_VPC_DESC_VPC_ATTR_RETURN', aws_result

                else
                #DescribeVpcAttribute failed

                    console.log 'vpc.DescribeVpcAttribute failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    vpc_model = new VPCModel()

    #public (exposes methods)
    vpc_model

