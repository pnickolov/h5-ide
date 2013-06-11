#*************************************************************************************
#* Filename     : reservedinstance_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:16
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'reservedinstance_service', 'reservedinstance_vo'], ( Backbone, reservedinstance_service, reservedinstance_vo ) ->

    ReservedInstanceModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : reservedinstance_vo.reservedinstance
        }

        ###### api ######
        #DescribeReservedDBInstances api (define function)
        DescribeReservedDBInstances : ( src, username, session_id ) ->

            me = this

            src.model = me

            reservedinstance_service.DescribeReservedDBInstances src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeReservedDBInstances succeed

                    reservedinstance_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeReservedDBInstances failed

                    console.log 'reservedinstance.DescribeReservedDBInstances failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_RETURN', aws_result


        #DescribeReservedDBInstancesOfferings api (define function)
        DescribeReservedDBInstancesOfferings : ( src, username, session_id ) ->

            me = this

            src.model = me

            reservedinstance_service.DescribeReservedDBInstancesOfferings src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeReservedDBInstancesOfferings succeed

                    reservedinstance_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeReservedDBInstancesOfferings failed

                    console.log 'reservedinstance.DescribeReservedDBInstancesOfferings failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_OFFERINGS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    reservedinstance_model = new ReservedInstanceModel()

    #public (exposes methods)
    reservedinstance_model

