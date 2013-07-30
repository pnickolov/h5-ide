#############################
#  View Mode for design/property/elb
#############################

define [ 'constant', 'backbone', 'MC' ], (constant) ->

    ElbAppModel = Backbone.Model.extend {

        init : ( elb_uid )->

            myElbComponent = MC.canvas_data.component[ elb_uid ]

            appData = MC.data.resource_list[ MC.canvas_data.region ]

            elb = $.extend true, {}, appData[ myElbComponent.resource.LoadBalancerName ]
            elb.name = myElbComponent.name


            elb.isInternet = elb.Scheme == "internet-facing"
            elb.HealthCheck.protocol = elb.HealthCheck.Target.split(":")[0]
            elb.HealthCheck.port     = elb.HealthCheck.Target.split(":")[1].split("/")[0]
            elb.HealthCheck.path     = elb.HealthCheck.Target.split("/")[1]


            elb.listenerDisplay = []

            if elb.ListenerDescriptions.member

              $.each elb.ListenerDescriptions.member, (i, listener) ->

                elb.listenerDisplay.push listener

            if elb.Subnets

              elb.isClassic = false

            else
              elb.isClassic = true

            elb.distribution = []
            $.each elb.AvailabilityZones.member, (i, zone_name) ->
              tmp = {}
              tmp.zone = zone_name
              tmp.health_instance = 0
              tmp.total_instance = 0

              if not elb.isClassic

                if elb.Subnets.member and elb.Subnets.member.constructor == Array

                    $.each elb.Subnets.member, (j, subnet_id) ->

                        if MC.data.resource_list[MC.canvas_data.region][subnet_id].availabilityZone == zone_name

                            tmp.subnet = subnet_id

                            return false

                else if elb.Subnets.member

                    tmp.subnet = elb.Subnets.member

              else
                tmp.subnet = null

              $.each MC.data.config[MC.canvas_data.region].zone.item, (i, zone) ->

                if zone.zoneName == zone_name and zone.zoneState == 'available'

                    tmp.health = true

                null

              elb.distribution.push tmp

            $.each elb.instance_state, ( i, instance ) ->

                zone = MC.data.resource_list[MC.canvas_data.region][instance.InstanceId].placement.availabilityZone

                $.each elb.distribution, ( j, az_detail ) ->

                    if az_detail.zone == zone and instance.State == 'InService'

                        az_detail.health_instance += 1

                    az_detail.total_instance += 1

                    return false


            this.set elb
    }

    new ElbAppModel()
