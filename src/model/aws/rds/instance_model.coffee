#*************************************************************************************
#* Filename     : instance_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:53
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'instance_service', 'base_model' ], ( Backbone, _, instance_service, base_model ) ->

    InstanceModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeDBInstances api (define function)
        DescribeDBInstances : ( src, username, session_id, region_name, instance_id=null, marker=null, max_records=null ) ->

            me = this

            src.model = me

            instance_service.DescribeDBInstances src, username, session_id, region_name, instance_id, marker, max_records, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'RDS_INS_DESC_DB_INSTANCES_RETURN', aws_result

                else
                #DescribeDBInstances failed

                    console.log 'instance.DescribeDBInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    instance_model = new InstanceModel()

    #public (exposes methods)
    instance_model

