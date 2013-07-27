#############################
#  View Mode for design/property/instance (app)
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], (constant) ->

    AppInstanceModel = Backbone.Model.extend {

        ###
        defaults :
            'instance' :
                'uid'            : ""
                'name'           : ""
                'running'        : false
                'launchTiem'     : ""
                'publicIP'       : ""
                'publicDNS'      : ""
                'privateIP'      : ""
                'privateDNS'     : ""
                'AMI'            : ""
                'keypair'        : ""
                'keypairURL'     : ""
                'EBS'            : false
                'tenancy'        : ""
                'rootDeviceType' : ""
                'blockDevice'    : ""
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
