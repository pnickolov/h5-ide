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

            @set attr

            # #Listener
            # listenerAry = elb_data.get 'ListenerDescriptions'
            # this.set 'listener_detail', {
            #     listenerAry: listenerAry
            # }

            # if MC.aws.vpc.getVPCUID()
            #     this.set 'az_detail', null
            #     # return

            # #AZ & Instance Info
            # azObj = {}
            # azObjAry = []
            # region = MC.canvas_data.region

            # if !MC.data.config[region].zone
            #     return

            # azAry = MC.data.config[region].zone.item
            # _.each azAry, (elem) ->
            #     azObj[elem.zoneName] = 0
            #     null

            # InstanceModel = Design.modelClassForType constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
            # allInstance = InstanceModel and InstanceModel.allObjects() or []

            # _.each allInstance, ( instance ) ->
            #     # subnetUID = compObj.resource.SubnetId.split('.')[0].slice(1)
            #     # subnetCompObj = MC.canvas_data.component[subnetUID]
            #     # azName = subnetCompObj.resource.AvailabilityZone
            #     azName = instance.get( 'Placement' ).AvailabilityZone
            #     azObj[azName]++
            #     null

            # # have az ##################################################################
            # if not @elb.get 'VpcId'
            #     azAry = @elb.get 'AvailabilityZones'
            #     _.each azObj, (value, key) ->
            #         obj = {}
            #         obj[key] = value

            #         selected = (key in azAry)

            #         # keep az name to short name
            #         # us-east-1a -> US East 1a

            #         keyAry = key.split('-')
            #         keyAry[0] = keyAry[0].toUpperCase()
            #         keyAry[1] = keyAry[1][0].toUpperCase() + keyAry[1].slice(1)
            #         keyStr = keyAry.join(' ')

            #         disable_selected = MC.aws.elb.haveAssociateInAZ(uid, key)

            #         azObjAry.push({
            #             az_name: keyStr,
            #             az_inner_name: key,
            #             disable_selected: disable_selected,
            #             instance_num: value,
            #             selected: selected
            #         })
            #         null

            #     azObjAry.sort (obj1, obj2) ->
            #         key1 = obj1.az_name
            #         length1 = key1.length
            #         key2 = obj2.az_name
            #         length2 = key2.length
            #         return key1.slice(length1) - key2.slice(length2)

            #     this.set 'az_detail', azObjAry
            # # have az ##################################################################

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

        removeAZFromELB: ( value ) ->
            azName = value
            elbAZAry = @elb.get 'AvailabilityZones'

            newAZAry = _.filter elbAZAry, (item) ->
                if azName is item
                    false
                else
                    true
            @elb.set 'AvailabilityZones', newAZAry

            null

        addAZToELB: ( value ) ->
            azName = value
            addAZToElb = true

            elbAZAry = @elb.get 'AvailabilityZones'

            _.each elbAZAry, (elem, index) ->
                if elem is azName
                    addAZToElb = false
                    null

            if addAZToElb
                elbAZAry.push azName
                @elb.set 'AvailabilityZones', elbAZAry

            null
    }

    new ElbModel()
