#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', "event", "Design", 'constant' ], ( PropertyModel, ide_event, Design, constant ) ->

    ElbModel = PropertyModel.extend {

        init : ( uid ) ->

            component = Design.instance().component( uid )

            attr        = component.toJSON()
            attr.uid    = uid
            attr.isVpc  = Design.instance().typeIsVpc()
            attr.is_elb = true

            # Format ping
            pingArr  = component.getHealthCheckTarget()
            attr.pingProtocol = pingArr[0]
            attr.pingPort     = pingArr[1]
            attr.pingPath     = pingArr[2]


            # Get AZ List
            if not attr.isVpc

                AzModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone )

                connectedAzMap = {}
                for ami in component.connectionTargets("ElbAmiAsso")
                    connectedAzMap[ ami.parent().get("name") ] = true

                reg = /-[\w]/g
                replaceFunc = (g)-> " " + g[1].toUpperCase()
                filterFunc  = (ch)-> ch.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

                azArr = AzModel.allPossibleAZ()
                for az in azArr
                    if attr.AvailabilityZones.indexOf( az.name ) isnt -1
                        az.selected = true

                    az.disabled    = connectedAzMap[ az.name ]
                    az.displayName = az.name.replace reg, replaceFunc
                    az.displayName = az.displayName[0].toUpperCase() + az.displayName.substr(1)

                    if az.id
                        azComp = Design.instance().component( az.id )
                        az.instanceCount = _.filter( azComp.children(), filterFunc ).length

                attr.azArray = azArr

            @set attr
            null

            # #Listener
            # listenerAry = elb_data.get 'ListenerDescriptions'
            # this.set 'listener_detail', {
            #     listenerAry: listenerAry
            # }

        setScheme   : ( value ) ->
            value = value is "internal"
            Design.instance().component( @get("uid") ).setInternal( value )

            # Trigger an event to tell canvas that we want an IGW
            if not value and Design.instance().typeIsVpc()
                ide_event.trigger ide_event.NEED_IGW
            null

        setElbCrossAZ : ( value )->
            Design.instance().component( @get("uid") ).set( "crossZone", !!value )
            null

        setHealthProtocol   : ( value ) ->
            Design.instance().component( @get("uid") ).setHealthCheckTarget( value )
            null

        setHealthPort: ( value ) ->
            Design.instance().component( @get("uid") ).setHealthCheckTarget( undefined, value )
            null

        setHealthPath: ( value ) ->
            Design.instance().component( @get("uid") ).setHealthCheckTarget( undefined, undefined, value )
            null

        setHealthInterval: ( value ) ->
            Design.instance().component( @get("uid") ).set("healthCheckInterval", value )
            null

        setHealthTimeout: ( value ) ->
            Design.instance().component( @get("uid") ).set("healthCheckTimeout", value )
            null

        setHealthUnhealth: ( value ) ->
            Design.instance().component( @get("uid") ).set("unHealthyThreshold", value )
            null

        setHealthHealth: ( value ) ->
            Design.instance().component( @get("uid") ).set("healthyThreshold", value )
            null

        setListenerAry: ( value ) ->
            console.log 'setHealthHealth = ' + value

            uid = @get 'uid'

            #clean ami
            currentCert = this.getCurrentCert( uid )
            delCertComp = true
            if currentCert
                currentCertUID = currentCert.uid
                _.each value, (obj, index) ->
                    elbProtocolValue = obj.Listener.Protocol
                    if elbProtocolValue isnt 'HTTPS' and elbProtocolValue isnt 'SSL'
                        value[index].Listener.SSLCertificateId = ''
                    else
                        delCertComp = false
                        value[index].Listener.SSLCertificateId = '@' + currentCertUID + '.resource.ServerCertificateMetadata.Arn'
                    null

                if delCertComp
                    if Design.instance().component( currentCertUID ) then Design.instance().component( currentCertUID ).remove()

            @elb.set 'ListenerDescriptions', value
            MC.aws.elb.updateRuleToElbSG uid

            null

        getCurrentCert: ( uid ) ->

            console.log 'getCurrentCert'

            if not uid
                uid = @get 'uid'

            certUID = ''
            listenerAry = @elb.get 'ListenerDescriptions'
            _.each listenerAry, (obj) ->
                certId = obj.Listener.SSLCertificateId
                if certId != ''
                    try
                        certUID = certId.split('.')[0].slice(1)
                        return false
                    catch err

            Design.instance().component( certUID )


        setListenerCert: ( value ) ->

            uid = @get 'uid'

            listenerAry = @elb.get 'ListenerDescriptions'

            currentCertUID = ''

            currentCert = this.getCurrentCert(uid)
            if currentCert and currentCert.id
                currentCertUID = currentCert.id

                #clean ami
                if (!value.name && !value.resource.PrivateKey && !value.resource.CertificateBody)
                    if Design.instance().component( currentCertUID ) then Design.instance().component( currentCertUID ).remove()

                    _.each listenerAry, (obj, index) ->
                        ListenerDescriptions = @elb.get 'ListenerDescriptions'
                        ListenerDescriptions[index].Listener.SSLCertificateId = ''
                        @elb.set 'ListenerDescriptions', ListenerDescriptions
                        null
            else
                currentCertUID = MC.guid()
                #currentCert = $.extend(true, {}, MC.canvas.SRVCERT_JSON).data

            if value and value.name and value.resource.PrivateKey and value.resource.CertificateBody
                currentCert.id = currentCertUID
                currentCert.name = value.name
                currentCert.PrivateKey = value.resource.PrivateKey
                currentCert.CertificateBody = value.resource.CertificateBody
                currentCert.CertificateChain = value.resource.CertificateChain
                currentCert.ServerCertificateMetadata.ServerCertificateName = value.name

                CertificateModel = Design.modelClassForType constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate
                certificate = new AWS_IAM_ServerCertificate currentCert

                @elb.associate certificate

            null



        updateElbAZ : ( azArray )->
            Design.instance().component( @get("uid") ).set("AvailabilityZones", azArray )
            null
    }

    new ElbModel()
