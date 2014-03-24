#############################
#  View Mode for design/property/elb
#############################

define [ '../base/model', 'constant', 'Design' ], ( PropertyModel, constant, Design ) ->

    ElbAppModel = PropertyModel.extend {

        defaults :
            'id'  : null

        init : ( uid )->

            this.set 'id', uid
            this.set 'uid', uid

            myElbComponent = Design.instance().component( uid )


            appData = MC.data.resource_list[ Design.instance().region() ]
            elb     = appData[ myElbComponent.get 'appId' ]

            if elb.ConnectionDraining
                if elb.ConnectionDraining.Enabled
                    elb.ConnectionDrainingInfo = "Enabled; Timeout: #{elb.ConnectionDraining.Timeout} seconds"
                else
                    elb.ConnectionDrainingInfo = 'Disabled'
            else
                elb.ConnectionDrainingInfo = 'Disabled'

            if not elb
                return false

            elb = $.extend true, {}, elb
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

            if elb.ListenerDescriptions.member

              $.each elb.ListenerDescriptions.member, (i, listener) ->

                elb.listenerDisplay.push listener

                if listener.Listener.SSLCertificateId

                  elb.server_certificate = listener.Listener.SSLCertificateId.split('/')[1]

                  null

            elb.isClassic  = Design.instance().typeIsClassic()
            elb.defaultVPC = Design.instance().typeIsDefaultVpc()

            elb.distribution = []

            subnetMap = {}

            allSubnet = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet ).allObjects()

            for subnet in allSubnet
                subnetMap[ subnet.id ] = subnet.get 'name'


            $.each elb.AvailabilityZones.member, (i, zone_name) ->
              tmp = {}
              tmp.zone = zone_name
              tmp.health_instance = 0
              tmp.total_instance = 0

              if not elb.isClassic

                if elb.Subnets.member and elb.Subnets.member.constructor == Array

                    $.each elb.Subnets.member, (j, subnet_id) ->
                        subnet = MC.data.resource_list[Design.instance().region()][subnet_id]
                        if subnet and subnet.availabilityZone is zone_name
                            tmp.subnet = subnetMap[ subnet_id ]
                            return false

                else if elb.Subnets.member

                    tmp.subnet = elb.Subnets.member

              else
                tmp.subnet = null

              $.each MC.data.config[Design.instance().region()].zone.item, (i, zone) ->

                if zone.zoneName == zone_name and zone.zoneState == 'available'

                    tmp.health = true

                null

              elb.distribution.push tmp

            elb.instance_state = elb.instance_state || []

            $.each elb.instance_state, ( i, instance ) ->

                zone = MC.data.resource_list[Design.instance().region()][instance.InstanceId].placement.availabilityZone

                $.each elb.distribution, ( j, az_detail ) ->

                    if az_detail.zone == zone and instance.State == 'InService'

                        az_detail.health_instance += 1

                    az_detail.total_instance += 1

                    return false

            @set elb
            @set "componentUid", myElbComponent.id
    }

    new ElbAppModel()
