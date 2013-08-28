#*************************************************************************************
#* Filename     : routetable_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:56
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'routetable_service', 'base_model' ], ( Backbone, _, routetable_service, base_model ) ->

    RouteTableModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeRouteTables api (define function)
        DescribeRouteTables : ( src, username, session_id, region_name, rt_ids=null, filters=null ) ->

            me = this

            src.model = me

            routetable_service.DescribeRouteTables src, username, session_id, region_name, rt_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeRouteTables succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'VPC_RT_DESC_RT_TBLS_RETURN', aws_result

                else
                #DescribeRouteTables failed

                    console.log 'routetable.DescribeRouteTables failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    routetable_model = new RouteTableModel()

    #public (exposes methods)
    routetable_model

