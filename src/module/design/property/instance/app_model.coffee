#############################
#  View Mode for design/property/instance (app)
#############################

define ['keypair_model', 'instance_model', 'constant', 'i18n!../../../../nls/lang.js' ,'backbone', 'MC' ], ( keypair_model, instance_model, constant, lang ) ->

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

            me.on 'EC2_KPDOWNLOAD_RETURN', ( result )->

                region_name = result.param[3]
                keypairname = result.param[4]
                os_type     = null
                key_data    = null
                instance    = null
                public_dns  = null
                cmd_line    = null
                login_user  = null

                instance_id      = me.get "instanceId"
                curr_keypairname = me.get "keyName"

                # The user has closed the dialog
                # Do nothing
                if curr_keypairname isnt keypairname
                    return

                ###
                # The EC2_KPDOWNLOAD_RETURN event won't fire when the result.is_error
                # is true. According to bugs in service models.
                ###

                if result.is_error
                    notification 'error', lang.ide.PROP_MSG_ERR_DOWNLOAD_KP_FAILED + keypairname
                    key_data = null
                else

                    key_data = result.resolved_data


                instance_data = MC.data.resource_list[ region_name ][ instance_id ]

                if instance_data && instance_data.imageId
                    os_type = MC.data.dict_ami[ instance_data.imageId ].osType

                #get password for windows AMI
                if os_type == 'win' and key_data
                    #me.getPasswordData instance_id, key_data.replace(/\n/g,'')
                    me.getPasswordData instance_id, key_data

                else
                    #linux

                    instance = MC.data.resource_list[ region_name ][ instance_id ]
                    if instance
                        instance_state = instance.instanceState.name

                    if instance_state == 'running'
                        switch os_type
                            when 'amazon' then login_user = 'ec2-user'
                            when 'ubuntu' then login_user = 'ubuntu'
                            else
                                login_user = 'root'

                        public_dns = instance.dnsName
                        cmd_line   = sprintf 'ssh -i %s.pem %s@%s', instance.keyName, login_user, instance.dnsName


                    option =
                        type      : 'linux'
                        cmd_line  : cmd_line
                        public_dns: public_dns

                    me.trigger "KP_DOWNLOADED", key_data, option

                null

            me.on 'EC2_INS_GET_PWD_DATA_RETURN', ( result ) ->

                region_name    = result.param[3]
                instance_id    = result.param[4]
                key_data       = result.param[5]
                instance       = null
                instance_state = null
                win_passwd     = null
                rdp            = null
                public_dns     = null


                curr_instance_id = me.get "instanceId"

                # The user has closed the dialog
                # Do nothing
                if curr_instance_id isnt instance_id
                    return


                if result.is_error
                    notification 'error', lang.ide.PROP_MSG_ERR_GET_PASSWD_FAILED + instance_id
                    key_data = null
                else
                    #right
                    instance = MC.data.resource_list[ region_name ][ instance_id ]
                    if instance
                        instance_state = instance.instanceState.name

                    if instance_state == 'running'
                        public_dns = instance.dnsName
                        rdp        = sprintf constant.RDP_TMPL, public_dns

                    win_passwd = result.resolved_data.passwordData


                option =
                    type      : 'win'
                    passwd    : win_passwd,
                    rdp       : rdp
                    public_dns: public_dns

                me.trigger "KP_DOWNLOADED", key_data, option

                null


            @set 'id', instance_id

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
                instance.blockDevice = ""
                if instance.blockDeviceMapping && instance.blockDeviceMapping.item
                    deviceName = []
                    for i in instance.blockDeviceMapping.item
                        deviceName.push i.deviceName

                    instance.blockDevice = deviceName.join ", "

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

            keypair_model.download {sender:@}, username, session, MC.canvas_data.region, keypairname
            null


        #get windows login password
        getPasswordData : ( instance_id, key_data ) ->

            username = $.cookie "usercode"
            session  = $.cookie "session_id"

            me = this
            instance_model.GetPasswordData {sender:me}, username, session, MC.canvas_data.region, instance_id, key_data
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
