#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', "event", "Design", 'constant' ], ( PropertyModel, ide_event, Design, constant ) ->

    ElbModel = PropertyModel.extend {

        init : ( uid ) ->

            component = Design.instance().component( uid )

            @getAppData( uid )

            attr        = component.toJSON()
            attr.uid    = uid
            attr.isVpc  = not Design.instance().typeIsClassic()

            # Format ping
            pingArr  = component.getHealthCheckTarget()
            attr.pingProtocol = pingArr[0]
            attr.pingPort     = pingArr[1]
            attr.pingPath     = pingArr[2]

            if attr.sslCert
                attr.sslCert = attr.sslCert.toJSON()

            # See if we need to should certificate
            for i in attr.listeners
                if i.protocol is "SSL" or i.protocol is "HTTPS"
                    attr.showCert = true
                    break

            # Get AZ List
            if not attr.isVpc

                AzModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone )

                connectedAzMap = {}
                for ami in component.connectionTargets("ElbAmiAsso")
                    if ami.parent().type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
                        az = ami.parent().parent()
                    else
                        az = ami.parent()
                    connectedAzMap[ az.get("name") ] = true

                reg = /-[\w]/g
                replaceFunc = (g)-> " " + g[1].toUpperCase()
                filterFunc  = (ch)-> ch.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

                azArr = AzModel.allPossibleAZ()
                for az in azArr
                    if connectedAzMap[ az.name ]
                        az.disabled = connectedAzMap[ az.name ]
                        az.selected = true
                    else
                        az.disabled = false
                        az.selected = attr.AvailabilityZones.indexOf( az.name ) isnt -1

                    az.displayName = az.name.replace reg, replaceFunc
                    az.displayName = az.displayName[0].toUpperCase() + az.displayName.substr(1)

                    if az.id
                        azComp = Design.instance().component( az.id )
                        az.instanceCount = _.filter( azComp.children(), filterFunc ).length

                attr.azArray = azArr

            # Get SSL Cert List
            currentSSLCert = component.connectionTargets("SslCertUsage")[0]
            allCertModelAry = Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate).allObjects()

            attr.noSSLCert = true
            attr.sslCertItem = _.map allCertModelAry, (sslCertModel) ->
                if currentSSLCert is sslCertModel then attr.noSSLCert = false

                {
                    uid: sslCertModel.id,
                    name: sslCertModel.get('name'),
                    selected: currentSSLCert is sslCertModel
                }
            @set attr
            null

        getAppData : ( uid )->
            uid = uid or @get("uid")

            myElbComponent = Design.instance().component( uid )

            appData = MC.data.resource_list[ Design.instance().region() ]
            elb     = appData[ myElbComponent.get 'appId' ]

            if not elb then return

            @set {
                appData    : true
                isInternet : elb.Scheme is 'internet-facing'
                DNSName    : elb.DNSName
                CanonicalHostedZoneNameID : elb.CanonicalHostedZoneNameID
            }
            null

        setScheme   : ( value ) ->
            value = value is "internal"
            Design.instance().component( @get("uid") ).setInternal( value )

            # Trigger an event to tell canvas that we want an IGW
            if not value and Design.instance().typeIsVpc()
                Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway ).tryCreateIgw()
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

        setListener: ( idx, value ) ->
            Design.instance().component( @get("uid") ).setListener( idx, value )
            null

        removeListener : ( idx )->
            Design.instance().component( @get("uid") ).removeListener( idx )
            null

        setCert : ( value )->
            Design.instance().component( @get("uid") ).connectionTargets("SslCertUsage")[0].set( value )
            null

        addCert : ( value )->
            SslCertModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate )
            (new SslCertModel( value )).assignTo( Design.instance().component( @get("uid") ) )
            null

        removeCert : ( value ) ->
            Design.instance().component( value ).remove()
            null

        updateElbAZ : ( azArray )->
            Design.instance().component( @get("uid") ).set("AvailabilityZones", azArray )
            null

        changeCert : ( certUID ) ->
            design = Design.instance()
            if certUID
                design.component( certUID ).assignTo( design.component( @get("uid") ) )
            else
                for cn in design.component( @get("uid") ).connections("SslCertUsage")
                    cn.remove()
            null

        updateCert : (certUID, certObj) ->
            Design.instance().component( certUID ).updateValue( certObj )
            null
        
        getOtherCertName : (currentName) ->

            allCertModelAry = Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate).allObjects()
            
            otherCertNameAry = []
            _.each allCertModelAry, (sslCertModel) ->
                sslCertName = sslCertModel.get('name')
                if currentName isnt sslCertName
                    otherCertNameAry.push(sslCertName)

            return otherCertNameAry

    }

    new ElbModel()
