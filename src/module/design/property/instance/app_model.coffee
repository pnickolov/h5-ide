#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model',
    'keypair_model',
    'instance_model',
    'instance_service'
    'constant',
    'i18n!nls/lang.js'
    'Design'

], ( PropertyModel, keypair_model, instance_model, instance_service, constant, lang, Design ) ->

    AppInstanceModel = PropertyModel.extend {

        defaults :
            'id' : null

        initialize : () ->


        setOsTypeAndLoginCmd: ( appId ) ->
            region = Design.instance().region()
            instance_data = MC.data.resource_list[ region ][ appId ]
            if instance_data && instance_data.imageId
                os_type = MC.data.dict_ami[ instance_data.imageId ].osType

            # below code are based on os_type
            if not os_type
                return

            if 'win|windows'.indexOf(os_type) > 0
                @set 'osType', 'windows'
            else
                @set 'osType', os_type

            if instance_data
                instance_state = instance_data.instanceState.name

            if instance_state == 'running'
                switch os_type
                    when 'amazon' then login_user = 'ec2-user'
                    when 'ubuntu' then login_user = 'ubuntu'
                    when 'redhat' then login_user = 'ec2-user'
                    else
                        login_user = 'root'

            if instance_data.ipAddress
                cmd_line = sprintf 'ssh -i %s.pem %s@%s', instance_data.keyName, login_user, instance_data.ipAddress
                @set 'loginCmd', cmd_line


        init : ( instance_id )->

            @set 'id', instance_id
            @set 'uid', instance_id

            myInstanceComponent = Design.instance().component( instance_id )

            # The instance_id might be component uid or aws id
            if myInstanceComponent
                instance_id = myInstanceComponent.get 'appId'
            else
                effective = Design.modelClassForType(constant.RESTYPE.INSTANCE).getEffectiveId instance_id
                myInstanceComponent = Design.instance().component( effective.uid )
                @set 'uid', effective.uid
                @set 'mid', effective.mid


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

                @setOsTypeAndLoginCmd myInstanceComponent.get 'appId'

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

            TYPE_ENI = constant.RESTYPE.ENI

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

        genPasswordHandler: ( action ) ->
            me = this
            ( result ) ->

                region_name    = result.param[3]
                instance_id    = result.param[4]
                key_data       = result.param[5]
                instance       = null
                instance_state = null
                win_passwd     = null
                rdp            = null

                curr_instance_id = me.get "instanceId"

                # Do nothing
                if curr_instance_id isnt instance_id
                    return

                if result.is_error
                    notification 'error', lang.ide.PROP_MSG_ERR_GET_PASSWD_FAILED + instance_id
                    key_data = null
                else
                    if result.resolved_data
                        win_passwd = result.resolved_data.passwordData


                if action is 'check'
                    me.trigger 'PASSWORD_STATE', !!win_passwd
                else
                    me.trigger "PASSWORD_GOT", win_passwd

                null

        #get windows login password
        getPasswordData : ( key_data, check ) ->
            instance_id      = @get "instanceId"
            #curr_keypairname = @get "keyName"
            username = $.cookie "usercode"
            session  = $.cookie "session_id"

            handler = @genPasswordHandler if check then 'check'
            instance_service.GetPasswordData( null, username, session, Design.instance().region(), instance_id, key_data ).then handler

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
