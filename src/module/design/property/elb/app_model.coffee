#############################
#  View Mode for design/property/elb
#############################

define [ 'constant', 'backbone', 'MC' ], (constant) ->

    ElbAppModel = Backbone.Model.extend {

        defaults :
            'id'    : null

        init : ( elb_uid )->

            this.set 'id', elb_uid

            myElbComponent = MC.canvas_data.component[ elb_uid ]

            appData = MC.data.resource_list[ MC.canvas_data.region ]

            elb = $.extend true, {}, appData[ myElbComponent.resource.LoadBalancerName ]
            elb.name = myElbComponent.name


            elb.isInternet = elb.Scheme == "internet-facing"
            elb.HealthCheck.protocol = elb.HealthCheck.Target.split(":")[0]
            elb.HealthCheck.port     = elb.HealthCheck.Target.split(":")[1].split("/")[0]
            elb.HealthCheck.path     = elb.HealthCheck.Target.split("/")[1]

            # DNS
            elb.AAAADNSName = "ipv6." + elb.DNSName
            elb.ADNSName    = "dualstack." + elb.DNSName


            elb.listenerDisplay = []

            if elb.ListenerDescriptions.member

              $.each elb.ListenerDescriptions.member, (i, listener) ->

                elb.listenerDisplay.push listener

                if listener.Listener.SSLCertificateId

                  elb.server_certificate = listener.Listener.SSLCertificateId.split('/')[1]

                  null

            if elb.Subnets

              elb.isClassic = false

            else
              elb.isClassic = true

            defaultVPC = false
            if MC.aws.aws.checkDefaultVPC()
                defaultVPC = true

            if defaultVPC or MC.canvas_data.component[elb_uid].resource.VpcId
                this.set 'have_vpc', true
            else
                this.set 'have_vpc', false

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

            elb.instance_state = elb.instance_state || []

            $.each elb.instance_state, ( i, instance ) ->

                zone = MC.data.resource_list[MC.canvas_data.region][instance.InstanceId].placement.availabilityZone

                $.each elb.distribution, ( j, az_detail ) ->

                    if az_detail.zone == zone and instance.State == 'InService'

                        az_detail.health_instance += 1

                    az_detail.total_instance += 1

                    return false

            elb.isclassic = if MC.canvas_data.platform is MC.canvas.PLATFORM_TYPE.EC2_CLASSIC then true else false

            this.set elb

        getSGList : () ->

            # resourceId = this.get 'id'

            # # find stack by resource id
            # resourceCompObj = null
            # _.each MC.canvas_data.component, (compObj, uid) ->
            #     if compObj.resource.InstanceId is resourceId
            #         resourceCompObj = compObj
            #     null

            # sgAry = []
            # if resourceCompObj
            #     sgAry = resourceCompObj.resource.SecurityGroupId

            uid = this.get 'id'
            sgAry = MC.canvas_data.component[uid].resource.SecurityGroups

            sgUIDAry = []
            _.each sgAry, (value) ->
                sgUID = value.slice(1).split('.')[0]
                sgUIDAry.push sgUID
                null

            return sgUIDAry
    }

    new ElbAppModel()
