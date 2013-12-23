#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    ElbModel = PropertyModel.extend {

        defaults :
            'elb_detail'      : null
            'health_detail'   : null
            'listener_detail' : null
            'az_detail'       : null
            'component'       : null
            'uid'             : null
            'is_elb'          : true
            'server_cert'     : null
            'have_vpc'        : null
            'cross_zone'      : null

        init : ( uid ) ->

            this.set 'uid', uid

            this.set 'is_elb', true

            #----------
            allComp = MC.canvas_data.component

            elb_data = Design.instance().component( uid )
            @elb = elb_data

            this.set 'component', elb_data
            #----------


            # cross zone
            crossZone = elb_data.get 'CrossZoneLoadBalancing'
            if crossZone and crossZone is 'true'
                this.set 'cross_zone', true
            else
                this.set 'cross_zone', false

            scheme = elb_data.get 'Scheme'

            # have igw ?
            haveIGW = false


            IGWModel = Design.modelClassForType constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
            allIGW = IGWModel and IGWModel.allObjects() or []

            igwCompAry = allIGW

            if igwCompAry.length isnt 0
                haveIGW = true

            elb_detail = {
                'isInternal' : scheme is 'internal',
                'haveIGW' : haveIGW
            }

            # if scheme is 'internal'
            #     MC.canvas.update uid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS
            # else
            #     MC.canvas.update uid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNET_CANVAS

            this.set 'elb_detail', elb_detail

            healthcheck = elb_data.get 'HealthCheck'

            target = healthcheck.Target

            #Ping Protocol
            protocol = target.split(':')[0]

            #Ping Port
            port = target.split(':')[1].split('/')[0]

            #Ping Path
            path = '/index.html'
            disabled_path = true
            if target.split('/')[1]
                path = '/' + target.split('/')[1]
                disabled_path = false

            #Health Check Interval
            interval = healthcheck.Interval

            #Response Timeout
            timeout = healthcheck.Timeout

            #Unhealthy Threshold
            unhealthy_threshold = healthcheck.UnhealthyThreshold

            #Healthy Threshold
            healthy_threshold = healthcheck.HealthyThreshold

            this.set 'health_detail', {
                target: target,
                protocol: protocol,
                port: port,
                path: path,
                interval: interval,
                timeout: timeout,
                disabled_path: disabled_path,
                unhealthy_threshold: unhealthy_threshold,
                healthy_threshold: healthy_threshold
            }

            #Listener
            listenerAry = elb_data.get 'ListenerDescriptions'
            this.set 'listener_detail', {
                listenerAry: listenerAry
            }

            if MC.aws.vpc.getVPCUID()
                this.set 'az_detail', null
                # return

            #AZ & Instance Info
            azObj = {}
            azObjAry = []
            region = MC.canvas_data.region

            if !MC.data.config[region].zone
                return

            azAry = MC.data.config[region].zone.item
            _.each azAry, (elem) ->
                azObj[elem.zoneName] = 0
                null

            InstanceModel = Design.modelClassForType constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
            allInstance = InstanceModel and InstanceModel.allObjects() or []

            _.each allInstance, ( instance ) ->
                # subnetUID = compObj.resource.SubnetId.split('.')[0].slice(1)
                # subnetCompObj = MC.canvas_data.component[subnetUID]
                # azName = subnetCompObj.resource.AvailabilityZone
                azName = compObj.resource.Placement.AvailabilityZone
                azObj[azName]++
                null

            # have az ##################################################################
            if not @elb.get 'VpcId'
                azAry = @elb.get 'AvailabilityZones'
                _.each azObj, (value, key) ->
                    obj = {}
                    obj[key] = value

                    selected = (key in azAry)

                    # keep az name to short name
                    # us-east-1a -> US East 1a

                    keyAry = key.split('-')
                    keyAry[0] = keyAry[0].toUpperCase()
                    keyAry[1] = keyAry[1][0].toUpperCase() + keyAry[1].slice(1)
                    keyStr = keyAry.join(' ')

                    disable_selected = MC.aws.elb.haveAssociateInAZ(uid, key)

                    azObjAry.push({
                        az_name: keyStr,
                        az_inner_name: key,
                        disable_selected: disable_selected,
                        instance_num: value,
                        selected: selected
                    })
                    null

                azObjAry.sort (obj1, obj2) ->
                    key1 = obj1.az_name
                    length1 = key1.length
                    key2 = obj2.az_name
                    length2 = key2.length
                    return key1.slice(length1) - key2.slice(length2)

                this.set 'az_detail', azObjAry
            # have az ##################################################################

            defaultVPC = false
            if MC.aws.aws.checkDefaultVPC()
                defaultVPC = true

            if defaultVPC or @elb.get 'VpcId'
                this.set 'have_vpc', true
            else
                this.set 'have_vpc', false

            null

        setELBName  : ( value ) ->
            console.log 'setELBName = ' + value

            uid = @get 'uid'

            # before, modify elb default sg name
            elbSG = MC.aws.elb.getElbDefaultSG uid
            if elbSG
                originELBName = @elb.get 'LoadBalancerName'
                newSGName = value + '-sg'
                elbSGUID = elbSG.uid
                elb = Design.instance().component( elbSGUID )
                elb.set 'name', newSGName
                elb.set 'GroupName', newSGName

            # after, modify elb name
            @elb.set 'name', value
            @elb.set 'LoadBalancerName', value

            null

        setScheme   : ( value ) ->
            console.log 'setScheme = ' + value

            uid = @get 'uid'

            component = MC.canvas_data.component[ uid ]

            if value is 'internal'
                @elb.set 'Scheme', 'internal'
            else
                @elb.set 'Scheme', 'internet-facing'

            if value is 'internal'
                MC.canvas.update uid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS
                MC.canvas.display(uid, 'port-elb-sg-in', true)
            else
                MC.canvas.update uid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNET_CANVAS
                MC.canvas.display(uid, 'port-elb-sg-in', false)

            component

        setHealthProtocol   : ( value ) ->
            console.log 'setHealthProtocol = ' + value

            healthcheck = @elb.get 'HealthCheck'
            target = healthcheck.Target
            new_target = value + ':' + target.split(':')[1]

            if value is 'TCP' or value is 'SSL'
                new_target = new_target.split('/')[0]
            else
                path = new_target.split('/')[1]
                if !path
                    new_target += '/index.html'

            healthcheck.Target = new_target

            @elb.set 'HealthCheck', healthcheck

            null

        setHealthPort: ( value ) ->
            console.log 'setHealthPort = ' + value

            healthcheck = @elb.get 'HealthCheck'
            target = healthcheck.Target
            new_target = target.split(':')[0] + ':' + value
            path = target.split('/')[1]
            if path
                new_target += '/' + path


            healthcheck.Target = new_target

            @elb.set 'HealthCheck', healthcheck

            null

        setHealthPath: ( value ) ->
            console.log 'setHealthPath = ' + value

            healthcheck = @elb.get 'HealthCheck'
            target = healthcheck.Target
            new_target = target.split('/')[0] + value

            healthcheck.Target = new_target

            @elb.set 'HealthCheck', healthcheck

            null

        setHealthInterval: ( value ) ->
            console.log 'setHealthInterval = ' + value

            healthcheck = @elb.get 'HealthCheck'
            healthcheck.Interval = Number(value)

            @elb.set 'HealthCheck', healthcheck

            null

        setHealthTimeout: ( value ) ->
            console.log 'setHealthTimeout = ' + value

            healthcheck = @elb.get 'HealthCheck'
            healthcheck.Timeout = Number(value)

            @elb.set 'HealthCheck', healthcheck

            null

        setHealthUnhealth: ( value ) ->
            console.log 'setHealthUnhealth = ' + value

            healthcheck = @elb.get 'HealthCheck'
            healthcheck.UnhealthyThreshold = Number(value)

            @elb.set 'HealthCheck', healthcheck

            null

        setHealthHealth: ( value ) ->
            console.log 'setHealthHealth = ' + value

            healthcheck = @elb.get 'HealthCheck'
            healthcheck.HealthyThreshold = Number(value)

            @elb.set 'HealthCheck', healthcheck

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

        getSGList : () ->
            sgAry = @elb.get 'SecurityGroups'

            sgUIDAry = []

            _.each sgAry, (value) ->
                sgUID = value.slice(1).split('.')[0]
                sgUIDAry.push sgUID
                null

            return sgUIDAry

        unAssignSGToComp : (sg_uid) ->

            originSGAry = @elb.get 'SecurityGroups'

            currentSGId = '@' + sg_uid + '.resource.GroupId'

            originSGAry = _.filter originSGAry, (value) ->
                value isnt currentSGId

            @elb.set 'SecurityGroups', originSGAry

            null

        assignSGToComp : (sg_uid) ->

            originSGAry = @elb.get 'SecurityGroups'

            currentSGId = '@' + sg_uid + '.resource.GroupId'

            if !Boolean(currentSGId in originSGAry)
                originSGAry.push currentSGId

            @elb.set 'SecurityGroups', originSGAry

            null

        setElbCrossAZ : ( value )->

            @elb.set 'CrossZoneLoadBalancing', String(value)

            null
    }

    new ElbModel()
