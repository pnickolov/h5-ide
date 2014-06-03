#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', "event", "Design", 'constant', 'sslcert_dropdown' ], ( PropertyModel, ide_event, Design, constant, SSLCertDropdown ) ->

    ElbModel = PropertyModel.extend {

        init : ( uid ) ->

            component = Design.instance().component( uid )

            @getAppData( uid )

            attr        = component.toJSON()
            attr.uid    = uid
            attr.isVpc  = true

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

                AzModel = Design.modelClassForType( constant.RESTYPE.AZ )

                connectedAzMap = {}
                for ami in component.connectionTargets("ElbAmiAsso")
                    if ami.parent().type is constant.RESTYPE.ASG
                        az = ami.parent().parent()
                    else
                        az = ami.parent()
                    connectedAzMap[ az.get("name") ] = true

                reg = /-[\w]/g
                replaceFunc = (g)-> " " + g[1].toUpperCase()
                filterFunc  = (ch)-> ch.type is constant.RESTYPE.INSTANCE

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
            allCertModelAry = Design.modelClassForType(constant.RESTYPE.IAM).allObjects()

            attr.noSSLCert = true
            attr.sslCertItem = _.map allCertModelAry, (sslCertModel) ->
                if currentSSLCert is sslCertModel then attr.noSSLCert = false

                disableCertEdit = false
                if sslCertModel.get('certId') and sslCertModel.get('arn')
                    disableCertEdit = true

                {
                    uid: sslCertModel.id,
                    name: sslCertModel.get('name'),
                    selected: currentSSLCert is sslCertModel,
                    disableCertEdit: disableCertEdit
                }

            if attr.ConnectionDraining
                if attr.ConnectionDraining.Enabled is true
                    attr.connectionDrainingEnabled = true
                    attr.connectionDrainingTimeout = attr.ConnectionDraining.Timeout
                else
                    attr.connectionDrainingEnabled = false

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
            if not value
                Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()
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
            SslCertModel = Design.modelClassForType( constant.RESTYPE.IAM )
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

            allCertModelAry = Design.modelClassForType(constant.RESTYPE.IAM).allObjects()

            otherCertNameAry = []
            _.each allCertModelAry, (sslCertModel) ->
                sslCertName = sslCertModel.get('name')
                if currentName isnt sslCertName
                    otherCertNameAry.push(sslCertName)

            return otherCertNameAry

        setConnectionDraining : (enabled, timeout) ->

            if not enabled
                timeout = null

            elbModel = Design.instance().component( @get("uid") )
            elbModel.set('ConnectionDraining', {
                Enabled: enabled,
                Timeout: timeout
            })

        setAdvancedProxyProtocol : (enable, portAry) ->

            elbModel = Design.instance().component( @get("uid") )
            elbModel.setPolicyProxyProtocol(enable, portAry)

        initNewSSLCertDropDown : (idx) ->

            that = this
            elbModel = Design.instance().component( @get("uid") )
            sslCertDropDown = new SSLCertDropdown()
            sslCertModel = elbModel.getSSLCert(idx)
            if sslCertModel
                sslCertDropDown.sslCertName = sslCertModel.get('name')

            sslCertDropDown.dropdown.on 'change', (sslCertId) ->
                listenerNum = $(this.el).parents('.elb-property-listener').index()
                Design.instance().component(that.get("uid")).setSSLCert(listenerNum, sslCertId)
            , sslCertDropDown

            return sslCertDropDown

    }

    new ElbModel()
