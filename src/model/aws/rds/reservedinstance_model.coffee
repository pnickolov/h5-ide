#*************************************************************************************
#* Filename     : reservedinstance_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:54
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'reservedinstance_service', 'base_model' ], ( Backbone, _, reservedinstance_service, base_model ) ->

    ReservedInstanceModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeReservedDBInstances api (define function)
        DescribeReservedDBInstances : ( src, username, session_id ) ->

            me = this

            src.model = me

            reservedinstance_service.DescribeReservedDBInstances src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeReservedDBInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_RETURN', aws_result

                else
                #DescribeReservedDBInstances failed

                    console.log 'reservedinstance.DescribeReservedDBInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeReservedDBInstancesOfferings api (define function)
        DescribeReservedDBInstancesOfferings : ( src, username, session_id ) ->

            me = this

            src.model = me

            reservedinstance_service.DescribeReservedDBInstancesOfferings src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeReservedDBInstancesOfferings succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_OFFERINGS_RETURN', aws_result

                else
                #DescribeReservedDBInstancesOfferings failed

                    console.log 'reservedinstance.DescribeReservedDBInstancesOfferings failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    reservedinstance_model = new ReservedInstanceModel()

    #public (exposes methods)
    reservedinstance_model

