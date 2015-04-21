#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model',
    'constant',
    'i18n!/nls/lang.js'
    'Design'
    'CloudResources'
    "ApiRequest"

], ( PropertyModel, constant, lang, Design, CloudResources, ApiRequest ) ->

    AppInstanceModel = PropertyModel.extend {

        defaults :
            'id' : null

        setOsTypeAndLoginCmd: ( appId ) ->

            region = Design.instance().region()
            instance_data = CloudResources(Design.instance().credentialId(), constant.RESTYPE.INSTANCE, region).get(appId)?.toJSON()
            if instance_data
                os_type = CloudResources( Design.instance().credentialId(), constant.RESTYPE.AMI, region ).get( instance_data.imageId )?.toJSON()

                if os_type then os_type = os_type.osType
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

            cmd_line = sprintf 'ssh -i %s.pem %s@%s', instance_data.keyName, login_user, instance_data.publicIpAddress or instance_data.privateIpAddress
            @set 'loginCmd', cmd_line


        init : ( instanceId )->
            if not @resModel
                console.warn "instance.app_model.init(): can not find InstanceModel"
            @set 'id', instanceId
            @set 'uid', instanceId

            if @effective
                @set 'uid', @effective.uid
                @set 'mid', @effective.mid
                appId = instanceId
            else
                appId = @resModel.get 'appId'
            if @resModel
                @set "userData", @resModel.get("userData")
            app_data = CloudResources(Design.instance().credentialId(), constant.RESTYPE.INSTANCE, Design.instance().region())

            if app_data?.get(appId)?.toJSON()
                instance = $.extend true, {}, app_data.get(appId)?.toJSON()
                @set "userDataEnabled" , (not Design.instance().get("agent").enabled and instance.rootDeviceType is "ebs")
                instance.name = if @resModel then @resModel.get 'name' else appId
                rdName = @resModel.getAmiRootDeviceName()

                if @resModel.isMesosSlave()
                    mesosData = {
                        isMesosSlave    : true
                    }
                    _.extend instance, mesosData

                # Possible value : running, stopped, pending...
                instance.state = MC.capitalize instance.instanceState.name
                instance.blockDevice = ""
                if instance.blockDeviceMapping && instance.blockDeviceMapping
                    deviceName = []
                    for i in instance.blockDeviceMapping
                        deviceName.push i.deviceName
                        if rdName is i.deviceName
                            rootDevice = i
                    instance.blockDevice = deviceName.join ", "

                    #RootDevice Data
                    if rootDevice
                        volume = CloudResources(Design.instance().credentialId(), constant.RESTYPE.VOL, Design.instance().region()).get(rootDevice.ebs.volumeId)?.toJSON()
                        if volume
                            if volume.attachmentSet
                                volume.name = volume.attachmentSet[0].device
                            @set "rootDevice", volume

                # Eni Data
                instance.eni = this.getEniData instance

                instance.app_view = false

                monitoringState = 'disabled'
                if instance.monitoring and instance.monitoring.state
                    monitoringState = instance.monitoring.state
                this.set 'monitoringState', monitoringState

                this.set instance

                @setOsTypeAndLoginCmd appId

            else
                return false

            null

        getEniData : ( instance_data ) ->

            if not instance_data.networkInterfaceSet
                return null

            for i in instance_data.networkInterfaceSet
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

            appData = CloudResources(Design.instance().credentialId(), constant.RESTYPE.ENI, Design.instance().region())

            if not appData.get(id)
                # Use data inside networkInterfaceSet
                data = $.extend true, {}, data
            else
                # Use data inside appData
                data = $.extend true, {}, appData.get( id )?.toJSON()

            data.name = if component then component.get 'name' else id
            if data.status == "in-use"
                data.isInUse = true

            data.sourceDestCheck = if data.sourceDestCheck then "enabled" else "disabled"

            for i in data.privateIpAddressesSet
                i.primary = i.primary == true

            data

        getPassword : ( key_data )->
            ApiRequest("ins_GetPasswordData", {
                region_name : Design.instance().region()
                instance_id : @get("instanceId")
                key_id      : Design.instance().credentialId()
                key_data    : key_data || undefined
            }).then ( data )->
                #data.GetPasswordDataResponse.passwordData
                #will restore after appservice improve
                ns = ""
                if data["ns0:GetPasswordDataResponse"]
                    ns = "ns0:"
                data[ns+"GetPasswordDataResponse"][ns+"passwordData"]

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
