#*************************************************************************************
#* Filename     : vpc_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:12
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'vpc_service', 'vpc_vo'], ( Backbone, vpc_service, vpc_vo ) ->

    VPCModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : vpc_vo.vpc
        }

        ###### api ######
        #DescribeVpcs api (define function)
        DescribeVpcs : ( src, username, session_id, region_name, vpc_ids=null, filters=null ) ->

            me = this

            src.model = me

            vpc_service.DescribeVpcs src, username, session_id, region_name, vpc_ids=null, filters=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVpcs succeed

                    vpc_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVpcs failed

                    console.log 'vpc.DescribeVpcs failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_VPC_DESC_VPCS_RETURN', aws_result


        #DescribeAccountAttributes api (define function)
        DescribeAccountAttributes : ( src, username, session_id, region_name, attribute_name ) ->

            me = this

            src.model = me

            vpc_service.DescribeAccountAttributes src, username, session_id, region_name, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAccountAttributes succeed

                    vpc_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeAccountAttributes failed

                    console.log 'vpc.DescribeAccountAttributes failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', aws_result


        #DescribeVpcAttribute api (define function)
        DescribeVpcAttribute : ( src, username, session_id, region_name, vpc_id, attribute ) ->

            me = this

            src.model = me

            vpc_service.DescribeVpcAttribute src, username, session_id, region_name, vpc_id, attribute, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVpcAttribute succeed

                    vpc_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVpcAttribute failed

                    console.log 'vpc.DescribeVpcAttribute failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_VPC_DESC_VPC_ATTR_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    vpc_model = new VPCModel()

    #public (exposes methods)
    vpc_model

