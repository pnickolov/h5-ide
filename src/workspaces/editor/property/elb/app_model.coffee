#############################
#  View Mode for design/property/elb
#############################

define [ '../base/model', 'constant', 'Design', "CloudResources" ], ( PropertyModel, constant, Design, CloudResources ) ->

    ElbAppModel = PropertyModel.extend {

        defaults :
            'id'  : null

        init : ( uid )->

            this.set 'id', uid
            this.set 'uid', uid

            myElbComponent = Design.instance().component( uid )


            elb = CloudResources(constant.RESTYPE.ELB, Design.instance().region()).get(myElbComponent.get("appId"))
            if not elb then return false

            elb = elb.toJSON()

            if elb.ConnectionDraining
                if elb.ConnectionDraining.Enabled
                    elb.ConnectionDrainingInfo = "Enabled; Timeout: #{elb.ConnectionDraining.Timeout} seconds"
                else
                    elb.ConnectionDrainingInfo = 'Disabled'
            else
                elb.ConnectionDrainingInfo = 'Disabled'

            elb.IdleTimeout = elb.ConnectionSettings?.IdleTimeout

            elb.name = myElbComponent.get 'name'


            elb.isInternet = elb.Scheme is 'internet-facing'

            # Format ping
            target     = elb.HealthCheck.Target
            splitIndex = target.indexOf(":")
            elb.HealthCheck.protocol = target.substring(0, splitIndex)
            target                   = target.substring(splitIndex+1)
            port                     = parseInt( target, 10 )

            if isNaN( port ) then port = 80

            elb.HealthCheck.port = port
            elb.HealthCheck.path = target.replace( /[^\/]+\//, "/" )

            # Cross Zone
            elb.CrossZone = if myElbComponent.get('crossZone') then "Enabled" else "Disabled"

            # DNS
            # elb.AAAADNSName = "ipv6.#{elb.DNSName}"
            # elb.ADNSName    = "dualstack.#{elb.DNSName}"


            elb.listenerDisplay = []

            if elb.ListenerDescriptions

              $.each elb.ListenerDescriptions, (i, listener) ->

                elb.listenerDisplay.push listener

                if listener.Listener.SSLCertificateId

                  listener.Listener.server_certificate = listener.Listener.SSLCertificateId.split('/')[1]

                  null

            elb.isClassic  = false
            elb.defaultVPC = false

            elb.distribution = []
            elbDistrMap = {}

            instanceStateObj = elb.InstanceStates

            _.each instanceStateObj, (stateObj) ->

                try

                    instanceId = stateObj.InstanceId
                    instanceStateCode = stateObj.ReasonCode
                    instanceState = stateObj.State
                    instanceStateDescription = stateObj.Description

                    instanceCompObj = Design.modelClassForType(constant.RESTYPE.INSTANCE).getEffectiveId(instanceId)
                    instanceUID = instanceCompObj.uid
                    instanceComp = Design.instance().component(instanceUID)

                    regionName = ''
                    if instanceComp

                        instanceName = instanceComp.get('name')

                        if instanceName is instanceId
                            instanceName = null

                        showStateObj = {
                            instance_name: instanceName
                            instance_id: instanceId
                            instance_state: (instanceState is 'InService')
                            instance_state_desc: instanceStateDescription
                        }

                        regionComp = null
                        if instanceComp.parent() and instanceComp.parent().parent()
                            regionComp = instanceComp.parent().parent()
                            if instanceComp.type is constant.RESTYPE.LC
                                regionComp = instanceComp.parent().parent().parent()
                        if regionComp
                            regionName = regionComp.get('name')

                    elbDistrMap[regionName] = elbDistrMap[regionName] || []
                    elbDistrMap[regionName].push showStateObj

                catch err

                    console.log 'Error: ELB Instance State Parse Failed'

            _.each elbDistrMap, (instanceAry, azName) ->

                isHealth = true
                _.each instanceAry, (instanceObj) ->
                    if not instanceObj.instance_state
                        isHealth = false
                    null

                elb.distribution.push({
                    zone: azName,
                    instance: instanceAry,
                    health: isHealth
                })

            elb.distribution = elb.distribution.sort (azObj1, azObj2) ->
                return azObj1.zone > azObj2.zone

            @set elb
            @set "componentUid", myElbComponent.id
    }

    new ElbAppModel()
