#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model',
    'keypair_model',
    'constant',
    'i18n!nls/lang.js'
    'Design'

], ( PropertyModel, keypair_model, constant, lang, Design ) ->

    AppInstanceModel = PropertyModel.extend {

        defaults :
            'id' : null

        initialize : () ->
            me = this

            @on 'EC2_KPDOWNLOAD_RETURN', ( result ) ->

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
                if 'win|windows'.indexOf(os_type) > 0 and key_data
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

                    if instance.ipAddress
                        cmd_line = sprintf 'ssh -i %s.pem %s@%s', instance.keyName, login_user, instance.ipAddress


                    option =
                        type      : 'linux'
                        cmd_line  : cmd_line

                    me.trigger "KP_DOWNLOADED", key_data, option

                null

            @on 'EC2_INS_GET_PWD_DATA_RETURN', ( result ) ->

                region_name    = result.param[3]
                instance_id    = result.param[4]
                key_data       = result.param[5]
                instance       = null
                instance_state = null
                win_passwd     = null
                rdp            = null


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

                    if instance_state == 'running' && instance.ipAddress
                        rdp = sprintf constant.RDP_TMPL, instance.ipAddress

                    if result.resolved_data
                        win_passwd = result.resolved_data.passwordData


                option =
                    type       : 'win'
                    passwd     : win_passwd
                    rdp        : rdp
                    public_dns : instance.ipAddress

                me.trigger "KP_DOWNLOADED", key_data, option

                null

        init : ( instance_id )->

            @set 'id', instance_id
            @set 'uid', instance_id

            myInstanceComponent = Design.instance().component( instance_id )

            # The instance_id might be component uid or aws id
            if myInstanceComponent
                instance_id = myInstanceComponent.get 'appId'
            else
                for instance in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance ).allObjects()
                    if instance.get("appId") is instance_id
                        @set "uid", instance.id
                        @set "memberId", "#{instance.id}_0"
                        found = true
                        break
                    else if instance.groupMembers
                        for member, index in instance.groupMembers()
                            if member and member.appId is instance_id
                                @set "uid", instance.id
                                @set "memberId", "#{member.id}_#{index + 1}"
                                found = true
                                break
                if not found
                    resource_list = MC.data.resource_list[ Design.instance().region() ]
                    for asg in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group ).allObjects()
                        data = resource_list[ asg.get("appId") ]
                        if not data then continue
                        data = data.Instances
                        if data.member then data = data.member
                        for obj in data
                            if obj is instance_id or obj.InstanceId is instance_id
                                @set "uid", asg.get("lc").id
                                @set "memberId", instance_id
                                break

            if not myInstanceComponent
                myInstanceComponent = Design.instance().component( @get "uid" )

            if not myInstanceComponent
                console.warn "instance.app_model.init(): can not find InstanceModel"

            app_data = MC.data.resource_list[ Design.instance().region() ]

            if app_data[ instance_id ]

                instance = $.extend true, {}, app_data[ instance_id ]
                instance.name = if myInstanceComponent then myInstanceComponent.get 'name' else instance_id
                rdName = myInstanceComponent.getAmiRootDeviceName()

                # Possible value : running, stopped, pending...
                instance.state = MC.capitalize instance.instanceState.name
                instance.blockDevice = ""
                if instance.blockDeviceMapping && instance.blockDeviceMapping.item
                    deviceName = []
                    for i in instance.blockDeviceMapping.item
                        deviceName.push i.deviceName
                        if rdName is i.deviceName
                            rootDevice = i
                    instance.blockDevice = deviceName.join ", "

                    #RootDevice Data
                    if rootDevice
                        volume = MC.data.resource_list[Design.instance().region()][ rootDevice.ebs.volumeId ]
                        if volume
                            if volume.attachmentSet
                                volume.name = volume.attachmentSet.item[0].device
                            @set "rootDevice", volume

                # Eni Data
                instance.eni = this.getEniData instance

                instance.app_view = if MC.canvas.getState() is 'appview' then true else false

                this.set instance

            else
                return false

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

            EniModel = Design.modelClassForType( TYPE_ENI )
            allEni = EniModel and EniModel.allObjects() or []

            for eni in allEni
                if eni.get 'appId' is id
                    component = eni
                    break

            appData = MC.data.resource_list[ Design.instance().region() ]

            if not appData[id]
                # Use data inside networkInterfaceSet
                data = $.extend true, {}, data
            else
                # Use data inside appData
                data = $.extend true, {}, appData[ id ]

            data.name = if component then component.get 'name' else id
            if data.status == "in-use"
                data.isInUse = true

            data.sourceDestCheck = if data.sourceDestCheck then "enabled" else "disabled"

            for i in data.privateIpAddressesSet.item
                i.primary = i.primary == true

            data

        downloadKP : ( keypairname ) ->
            username = $.cookie "usercode"
            session  = $.cookie "session_id"

            keypair_model.download {sender:@}, username, session, Design.instance().region(), keypairname
            null


        #get windows login password
        getPasswordData : ( instance_id, key_data ) ->

            username = $.cookie "usercode"
            session  = $.cookie "session_id"

            me = this
            instance_model.GetPasswordData {sender:me}, username, session, Design.instance().region(), instance_id, key_data
            null


        getAMI : ( ami_id ) ->
            MC.data.dict_ami[ami_id]


        getEni : () ->

            instance = Design.instance().component( @get 'uid'  )

            eni = instance.getEmbedEni()

            if not eni
                return

            eni_obj     = eni.toJSON()
            eni_obj.ips = eni.getIpArray()
            eni_obj.ips[0].unDeletable = true

            @set "eni", eni_obj
            @set "multi_enis", instance.connections("EniAttachment").length > 0
            null
    }

    new AppInstanceModel()
