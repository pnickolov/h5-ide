#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], (constant) ->

    ElbModel = Backbone.Model.extend {

        defaults :
            'elb_detail'    : null
            'health_detail' : null
            'listener_detail'   :   null
            'az_detail' :   null

        initELB : ( uid ) ->
            allComp = MC.canvas_data.component
            
            elb_data = MC.canvas_data.component[ uid ]
            scheme = elb_data.resource.Scheme

            # have igw ?
            haveIGW = false

            igwCompAry = _.filter allComp, (obj) ->
                obj.type is 'AWS.VPC.InternetGateway'
            if igwCompAry.length isnt 0
                haveIGW = true

            elb_detail = {
                'isInternal' : scheme is 'internal',
                'haveIGW' : haveIGW
            }

            this.set 'elb_detail', elb_detail

            healthcheck = elb_data.resource.HealthCheck

            target = healthcheck.Target

            #Ping Protocol
            protocol = target.split(':')[0]

            #Ping Port
            port = target.split(':')[1].split('/')[0]

            #Ping Path
            path = '/' + target.split('/')[1]

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
                unhealthy_threshold: unhealthy_threshold,
                healthy_threshold: healthy_threshold
            }

            #Listener
            listenerAry = elb_data.resource.ListenerDescriptions
            this.set 'listener_detail', {
                listenerAry: listenerAry
            }

            #AZ & Instance Info
            azObj = {}
            azObjAry = []

            region = MC.canvas_data.region
            azAry = MC.data.config[region].zone.item
            _.each azAry, (elem) ->
                azObj[elem.zoneName] = 0
                null

            _.each MC.canvas_data.component, (compObj) ->
                compType = compObj.type
                if compType is 'AWS.EC2.Instance'
                    # subnetUID = compObj.resource.SubnetId.split('.')[0].slice(1)
                    # subnetCompObj = MC.canvas_data.component[subnetUID]
                    # azName = subnetCompObj.resource.AvailabilityZone
                    azName = compObj.resource.Placement.AvailabilityZone
                    azObj[azName]++
                null

            azAry = MC.canvas_data.component[uid].resource.AvailabilityZones
            _.each azObj, (value, key) ->
                obj = {}
                obj[key] = value

                selected = (key in azAry)
                azObjAry.push({
                    az_name: key,
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

            null

        setELBName  : ( uid, value ) ->
            console.log 'setELBName = ' + value
            MC.canvas_data.component[ uid ].name = value
            MC.canvas_data.component[ uid ].LoadBalancerName = value

            null

        getELBName  : ( uid ) ->
            console.log 'getELBName = ' + value
            MC.canvas_data.component[ uid ].LoadBalancerName

            #this.set 'set_host', 'host'

        setScheme   : ( uid, value ) ->
            console.log 'setScheme = ' + value

            if value is 'internal'
                MC.canvas_data.component[ uid ].resource.Scheme = 'internal'
            else
                MC.canvas_data.component[ uid ].resource.Scheme = 'internet-facing'

            null

        setHealthProtocol   : ( uid, value ) ->
            console.log 'setHealthProtocol = ' + value
            target = MC.canvas_data.component[ uid ].resource.HealthCheck.Target
            new_target = value + ':' + target.split(':')[1]

            MC.canvas_data.component[ uid ].resource.HealthCheck.Target = new_target

            null

        setHealthPort: ( uid, value ) ->
            console.log 'setHealthPort = ' + value
            target = MC.canvas_data.component[ uid ].resource.HealthCheck.Target
            new_target = target.split(':')[0] + ':' + value + '/' + target.split('/')[1]

            MC.canvas_data.component[ uid ].resource.HealthCheck.Target = new_target

            null

        setHealthPath: ( uid, value ) ->
            console.log 'setHealthPath = ' + value
            target = MC.canvas_data.component[ uid ].resource.HealthCheck.Target
            new_target = target.split('/')[0] + value

            MC.canvas_data.component[ uid ].resource.HealthCheck.Target = new_target

            null

        setHealthInterval: ( uid, value ) ->
            console.log 'setHealthInterval = ' + value

            MC.canvas_data.component[ uid ].resource.HealthCheck.Interval = Number(value)

            null

        setHealthTimeout: ( uid, value ) ->
            console.log 'setHealthTimeout = ' + value

            MC.canvas_data.component[ uid ].resource.HealthCheck.Timeout = Number(value)

            null

        setHealthUnhealth: ( uid, value ) ->
            console.log 'setHealthUnhealth = ' + value

            MC.canvas_data.component[ uid ].resource.HealthCheck.UnhealthyThreshold = Number(value)

            null

        setHealthHealth: ( uid, value ) ->
            console.log 'setHealthHealth = ' + value

            MC.canvas_data.component[ uid ].resource.HealthCheck.HealthyThreshold = Number(value)

            null

        setListenerAry: ( uid, value ) ->
            console.log 'setHealthHealth = ' + value

            #clean ami
            currentCert = this.getCurrentCert(uid)
            delCertComp = true
            if currentCert
                currentCertUID = currentCert.uid
                _.each value, (obj, index) ->
                    elbProtocolValue = obj.Listener.Protocol
                    if elbProtocolValue isnt 'HTTPS' and elbProtocolValue isnt 'SSL'
                        value[index].Listener.SSLCertificateId = ''
                    else
                        delCertComp = false
                    null

                if delCertComp
                    delete MC.canvas_data.component[currentCertUID]

            MC.canvas_data.component[uid].resource.ListenerDescriptions = value

            null

        getCurrentCert: ( uid ) ->
            console.log 'getCurrentCert'

            certUID = ''
            listenerAry = MC.canvas_data.component[ uid ].resource.ListenerDescriptions
            _.each listenerAry, (obj) ->
                certId = obj.Listener.SSLCertificateId
                if certId != ''
                    try
                        certUID = certId.split('.')[0].slice(1)
                        return false
                    catch err

            MC.canvas_data.component[certUID]

        setListenerCert: ( uid, value ) ->

            listenerAry = MC.canvas_data.component[uid].resource.ListenerDescriptions

            currentCertUID = ''

            currentCert = this.getCurrentCert(uid)
            if currentCert and currentCert.uid
                currentCertUID = currentCert.uid

                #clean ami
                if (!value.name && !value.resource.PrivateKey && !value.resource.CertificateBody)
                    delete MC.canvas_data.component[currentCertUID]
                    _.each listenerAry, (obj, index) ->
                        MC.canvas_data.component[uid].resource.ListenerDescriptions[index].Listener.SSLCertificateId = ''
                        null
            else
                currentCertUID = MC.guid()
                currentCert = $.extend(true, {}, MC.canvas.SRVCERT_JSON).data

            if value and value.name and value.resource.PrivateKey and value.resource.CertificateBody
                currentCert.uid = currentCertUID
                currentCert.name = value.name
                currentCert.resource.PrivateKey = value.resource.PrivateKey
                currentCert.resource.CertificateBody = value.resource.CertificateBody
                currentCert.resource.CertificateChain = value.resource.CertificateChain

                MC.canvas_data.component[currentCertUID] = currentCert

                certRef = '@' + currentCertUID + '.resource.ServerCertificateMetadata.Arn'
                _.each listenerAry, (obj, index) ->
                    elbProtocolValue = obj.Listener.Protocol
                    if elbProtocolValue is 'HTTPS' or elbProtocolValue is 'SSL'
                        MC.canvas_data.component[uid].resource.ListenerDescriptions[index].Listener.SSLCertificateId = certRef
                    else
                        MC.canvas_data.component[uid].resource.ListenerDescriptions[index].Listener.SSLCertificateId = ''

                    null

            null

        removeAZFromELB: ( uid, value ) ->

            azName = value
            elbComp = MC.canvas_data.component[uid]
            elbAZAry = elbComp.resource.AvailabilityZones
            newAZAry = _.filter elbAZAry, (item) ->
                if azName is item
                    false
                else
                    true

            MC.canvas_data.component[uid].resource.AvailabilityZones = newAZAry

            null

        addAZToELB: ( uid, value ) ->

            azName = value
            addAZToElb = true
            elbComp = MC.canvas_data.component[uid]
            elbAZAry = elbComp.resource.AvailabilityZones
            _.each elbAZAry, (elem, index) ->
                if elem is azName
                    addAZToElb = false
                    null

            if addAZToElb
                MC.canvas_data.component[uid].resource.AvailabilityZones.push(azName)

            null

    }

    model = new ElbModel()

    return model