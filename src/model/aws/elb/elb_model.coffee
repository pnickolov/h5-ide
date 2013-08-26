#*************************************************************************************
#* Filename     : elb_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:51
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'elb_service', 'base_model' ], ( Backbone, _, elb_service, base_model ) ->

    ELBModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeInstanceHealth api (define function)
        DescribeInstanceHealth : ( src, username, session_id, region_name, elb_name, instance_ids=null ) ->

            me = this

            src.model = me

            elb_service.DescribeInstanceHealth src, username, session_id, region_name, elb_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInstanceHealth succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ELB__DESC_INS_HLT_RETURN', aws_result

                else
                #DescribeInstanceHealth failed

                    console.log 'elb.DescribeInstanceHealth failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeLoadBalancerPolicies api (define function)
        DescribeLoadBalancerPolicies : ( src, username, session_id, region_name, elb_name=null, policy_names=null ) ->

            me = this

            src.model = me

            elb_service.DescribeLoadBalancerPolicies src, username, session_id, region_name, elb_name, policy_names, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLoadBalancerPolicies succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ELB__DESC_LB_PCYS_RETURN', aws_result

                else
                #DescribeLoadBalancerPolicies failed

                    console.log 'elb.DescribeLoadBalancerPolicies failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeLoadBalancerPolicyTypes api (define function)
        DescribeLoadBalancerPolicyTypes : ( src, username, session_id, region_name, policy_type_names=null ) ->

            me = this

            src.model = me

            elb_service.DescribeLoadBalancerPolicyTypes src, username, session_id, region_name, policy_type_names, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLoadBalancerPolicyTypes succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ELB__DESC_LB_PCY_TYPS_RETURN', aws_result

                else
                #DescribeLoadBalancerPolicyTypes failed

                    console.log 'elb.DescribeLoadBalancerPolicyTypes failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeLoadBalancers api (define function)
        DescribeLoadBalancers : ( src, username, session_id, region_name, elb_names=null, marker=null ) ->

            me = this

            src.model = me

            elb_service.DescribeLoadBalancers src, username, session_id, region_name, elb_names, marker, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLoadBalancers succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ELB__DESC_LBS_RETURN', aws_result

                else
                #DescribeLoadBalancers failed

                    console.log 'elb.DescribeLoadBalancers failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    elb_model = new ELBModel()

    #public (exposes methods)
    elb_model

