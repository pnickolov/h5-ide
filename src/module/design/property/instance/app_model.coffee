#############################
#  View Mode for design/property/instance (app)
#############################

define ['keypair_model', 'constant', 'backbone', 'MC' ], ( keypair_model, constant ) ->

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

            # Keypair Component
            keypairUid = MC.extractID( myInstanceComponent.resource.KeyName )
            myKeypairComponent = MC.canvas_data.component[ keypairUid ]

            instance.keyName = myKeypairComponent.resource.KeyName

            # Eni Data
            instance.eni = this.getEniData instance

            this.set instance

            null

        getEniData : ( instance_data ) ->
            for i in instance_data.networkInterfaceSet.item
                if i.attachment.deviceIndex == "0"
                    id = i.networkInterfaceId
                    break

            TYPE_ENI = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

            if not id
                return null

            for key, value of MC.canvas_data.component
                if value.type == TYPE_ENI && value.resource.NetworkInterfaceId == id
                    component = value
                    break

            data = $.extend true, {}, MC.data.resource_list[ MC.canvas_data.region ][ id ]

            if not data
                return null

            data.name = component.name
            if data.status == "in-use"
                data.isInUse = true

            data.sourceDestCheck = if data.sourceDestCheck is "true" then "enabled" else "disabled"

            for i in data.privateIpAddressesSet.item
                i.primary = i.primary == "true"

            data

        downloadKP : ( keypairname ) ->
            username = $.cookie "usercode"
            session  = $.cookie "session_id"

            keypair_model.download {sender:this}, username, session, MC.canvas_data.region, keypairname

            self = this
            self.once 'EC2_KPDOWNLOAD_RETURN', ( data )->

                if data.is_error
                    notification 'error', "Cannot download keypair: " + keypairname
                    data = null
                else
                    data = data.resolved_data
                self.trigger "KP_DOWNLOADED", data


    }

    new AppInstanceModel()
