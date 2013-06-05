#*************************************************************************************
#* Filename     : routetable_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:12
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'routetable_service', 'routetable_vo'], ( Backbone, routetable_service, routetable_vo ) ->

    RouteTableModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : routetable_vo.routetable
        }

        ###### api ######
        #DescribeRouteTables api (define function)
        DescribeRouteTables : ( src, username, session_id, region_name, rt_ids=null, filters=null ) ->

            me = this

            src.model = me

            routetable_service.DescribeRouteTables src, username, session_id, region_name, rt_ids=null, filters=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeRouteTables succeed

                    routetable_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeRouteTables failed

                    console.log 'routetable.DescribeRouteTables failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'VPC_RT_DESC_RT_TBLS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    routetable_model = new RouteTableModel()

    #public (exposes methods)
    routetable_model

