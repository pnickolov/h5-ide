#*************************************************************************************
#* Filename     : elb_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:13
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'elb_service'], ( Backbone, elb_service) ->

    ELBModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeInstanceHealth api (define function)
        DescribeInstanceHealth : ( src, username, session_id, region_name, elb_name, instance_ids=null ) ->

            me = this

            src.model = me

            elb_service.DescribeInstanceHealth src, username, session_id, region_name, elb_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInstanceHealth succeed

                    elb_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeInstanceHealth failed

                    console.log 'elb.DescribeInstanceHealth failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'ELB__DESC_INS_HLT_RETURN', aws_result


        #DescribeLoadBalancerPolicies api (define function)
        DescribeLoadBalancerPolicies : ( src, username, session_id, region_name, elb_name=null, policy_names=null ) ->

            me = this

            src.model = me

            elb_service.DescribeLoadBalancerPolicies src, username, session_id, region_name, elb_name, policy_names, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLoadBalancerPolicies succeed

                    elb_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeLoadBalancerPolicies failed

                    console.log 'elb.DescribeLoadBalancerPolicies failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'ELB__DESC_LB_PCYS_RETURN', aws_result


        #DescribeLoadBalancerPolicyTypes api (define function)
        DescribeLoadBalancerPolicyTypes : ( src, username, session_id, region_name, policy_type_names=null ) ->

            me = this

            src.model = me

            elb_service.DescribeLoadBalancerPolicyTypes src, username, session_id, region_name, policy_type_names, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLoadBalancerPolicyTypes succeed

                    elb_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeLoadBalancerPolicyTypes failed

                    console.log 'elb.DescribeLoadBalancerPolicyTypes failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'ELB__DESC_LB_PCY_TYPS_RETURN', aws_result


        #DescribeLoadBalancers api (define function)
        DescribeLoadBalancers : ( src, username, session_id, region_name, elb_names=null, marker=null ) ->

            me = this

            src.model = me

            elb_service.DescribeLoadBalancers src, username, session_id, region_name, elb_names, marker, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLoadBalancers succeed

                    elb_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeLoadBalancers failed

                    console.log 'elb.DescribeLoadBalancers failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'ELB__DESC_LBS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    elb_model = new ELBModel()

    #public (exposes methods)
    elb_model

