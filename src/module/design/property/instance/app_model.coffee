#############################
#  View Mode for design/property/instance (app)
#############################

define ['backbone', 'MC' ], () ->

    AppInstanceModel = Backbone.Model.extend {

        ###
        defaults :
            'instance' : # ( Extra Propeties )
                isRunning   : false
                isPending   : false
                blockDevice : ""

        ###


        init : ( instance_id )->

            myInstanceComponent = MC.canvas_data.component[ instance_id ]

            instance_id = myInstanceComponent.resource.InstanceId

            app_data = MC.data.resource_list[ MC.canvas_data.region ]

            instance = $.extend true, {}, app_data[ instance_id ]
            instance.name = myInstanceComponent.name

            # Possible value : running, stopped, pending...
            instance.isRunning = instance.instanceState.name == "running"
            instance.isPending = instance.instanceState.name == "pending"
            instance.instanceState.name = MC.capitalize instance.instanceState.name
            instance.blockDevice = ( i.deviceName for i in instance.blockDeviceMapping.item ).join ", "

            this.set "instance", instance

            null
    }

    new AppInstanceModel()
