###
Description:
    model know service interface, and provide operation to vo
Action:
    1.define vo
    2.provide encapsulation of api for controller
    3.dispatch event to controller
###

define [ 'backbone', 'instance_service', 'instance_vo'], ( Backbone, instance_service, instance_vo ) ->

    InstancesModel = Backbone.Model.extend {

        #vo (declare variable)
        defaults : {
            instanceList : []
        }

        #DescribeInstances api (define function)
        describeInstances : ( username, session_id, region_name, instance_ids = null, filters = null ) ->

            me = this

            instance_service.DescribeInstances username, password, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInstances succeed

                    instanceList = aws_result.resolved_data

                else
                #DescribeInstances failed

                    console.log 'describeInstances failed, error is ' + aws_result.error_message

                #dispatch event (dispatch to js/login/login whenever login succeed or failed)
                me.trigger 'EC2_INS_DESC_INSTANCES_RETURN', aws_result

    }

    #private (instantiation)
    instances_model = new InstancesModel()

    #public (exposes methods)
    instances_model
