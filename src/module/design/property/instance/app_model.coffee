#############################
#  View Mode for design/property/instance (app)
#############################

define ['keypair_model', 'constant', 'i18n!../../../../nls/lang.js' ,'backbone', 'MC' ], ( keypair_model, constant, lang ) ->

    AppInstanceModel = Backbone.Model.extend {

        ###
        defaults :
            'instance' : # ( Extra Propeties )
                isRunning   : false
                isPending   : false
                blockDevice : ""

        ###

        defaults :
            'id' : null

        init : ( instance_id )->


            me = this
            me.set 'id', instance_id
            me.on 'EC2_KPDOWNLOAD_RETURN', ( result )->

                keypairname = result.param[4]

                if result.is_error
                    notification 'error', lang.ide.PROP_MSG_ERR_DOWNLOAD_KP_FAILED + keypairname
                    data = null
                else

                    data = result.resolved_data
                me.trigger "KP_DOWNLOADED", data

                null



            myInstanceComponent = MC.canvas_data.component[ instance_id ]

            # The instance_id might be component uid or aws id
            if myInstanceComponent
                instance_id = myInstanceComponent.resource.InstanceId

            app_data = MC.data.resource_list[ MC.canvas_data.region ]

            if app_data[ instance_id ]

                instance = $.extend true, {}, app_data[ instance_id ]
                instance.name = if myInstanceComponent then myInstanceComponent.name else instance_id

                # Possible value : running, stopped, pending...
                instance.isRunning = instance.instanceState.name == "running"
                instance.isPending = instance.instanceState.name == "pending"
                instance.instanceState.name = MC.capitalize instance.instanceState.name
                instance.blockDevice = ( i.deviceName for i in instance.blockDeviceMapping.item ).join ", "

                # Keypair Component
                # keypairUid = MC.extractID( myInstanceComponent.resource.KeyName )
                # myKeypairComponent = MC.canvas_data.component[ keypairUid ]

                # instance.keyName = myKeypairComponent.resource.KeyName

                # Eni Data
                instance.eni = this.getEniData instance

                this.set instance

            else

                console.log 'Can not found data for this instance: ' + instance_id

            null

        getEniData : ( instance_data ) ->

            if not instance_data.networkInterfaceSet
                return null

            for i in instance_data.networkInterfaceSet.item
                if i.attachment.deviceIndex == "0"
                    id = i.networkInterfaceId
                    data = i
                    break

            TYPE_ENI = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

            if not id
                return null

            for key, value of MC.canvas_data.component
                if value.type == TYPE_ENI && value.resource.NetworkInterfaceId == id
                    component = value
                    break

            appData = MC.data.resource_list[ MC.canvas_data.region ]

            if not appData[id]
                # Use data inside networkInterfaceSet
                data = $.extend true, {}, data
            else
                # Use data inside appData
                data = $.extend true, {}, appData[ id ]

            data.name = if component then component.name else id
            if data.status == "in-use"
                data.isInUse = true

            data.sourceDestCheck = if data.sourceDestCheck is "true" then "enabled" else "disabled"

            for i in data.privateIpAddressesSet.item
                i.primary = i.primary == "true"

            data

        downloadKP : ( keypairname ) ->
            username = $.cookie "usercode"
            session  = $.cookie "session_id"

            me = this
            keypair_model.download {sender:me}, username, session, MC.canvas_data.region, keypairname
            null

        getAMI : ( ami_id ) ->
            MC.data.dict_ami[ami_id]

        getSGList : () ->

            # resourceId = this.get 'id'

            # # find stack by resource id
            # resourceCompObj = null
            # _.each MC.canvas_data.component, (compObj, uid) ->
            #     if compObj.resource.InstanceId is resourceId
            #         resourceCompObj = compObj
            #     null

            # sgAry = []
            # if resourceCompObj
            #     sgAry = resourceCompObj.resource.SecurityGroupId

            uid = this.get 'id'
            sgAry = MC.canvas_data.component[uid].resource.SecurityGroupId

            sgUIDAry = []
            _.each sgAry, (value) ->
                sgUID = value.slice(1).split('.')[0]
                sgUIDAry.push sgUID
                null

            return sgUIDAry

    }

    new AppInstanceModel()
