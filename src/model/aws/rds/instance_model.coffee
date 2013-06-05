#*************************************************************************************
#* Filename     : instance_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:27:09
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'instance_service', 'instance_vo'], ( Backbone, instance_service, instance_vo ) ->

    InstanceModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : instance_vo.instance
        }

        ###### api ######
        #DescribeDBInstances api (define function)
        DescribeDBInstances : ( src, username, session_id, region_name, instance_id=null, marker=null, max_records=null ) ->

            me = this

            src.model = me

            instance_service.DescribeDBInstances src, username, session_id, region_name, instance_id=null, marker=null, max_records=null, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDBInstances succeed

                    instance_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeDBInstances failed

                    console.log 'instance.DescribeDBInstances failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'RDS_INS_DESC_DB_INSTANCES_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    instance_model = new InstanceModel()

    #public (exposes methods)
    instance_model

