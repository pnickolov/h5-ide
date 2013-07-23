#############################
#  View Mode for design/property/az
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    AZModel = Backbone.Model.extend {

        defaults :
            'set_availability_zone'    : null
            'get_availability_zone'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getRenderData : ( uid ) ->
            data =
                id        : uid
                component : MC.canvas_data.layout.component.group[uid]
                az_list   : MC.data.config[ MC.canvas_data.region ]

            if data.az_list && data.az_list.zone
                data.az_list = data.az_list.zone.item
            else
                data.az_list = null

            data

        possibleAZList : ( datalist, selectedItemName ) ->
            if !datalist
                return

            used_list = {}
            for uid, az of MC.canvas_data.layout.component.group
                used_list[az.name] = true

            possible_list = []
            for az in datalist
                if az.zoneName == selectedItemName or used_list[az.zoneName] != true
                    possible_list.push
                        name      : az.zoneName
                        selected  : az.zoneName  == selectedItemName
                        available : az.zoneState =="available"

            possible_list

        setNewAZ : ( oldZoneID, newZone ) ->
            oldZone = MC.canvas_data.layout.component.group[ oldZoneID ]

            # The property panel is not representing the current canvas,
            # which should be a bug.
            if oldZone == undefined
                console.log "[Error!] Trying to modify az which is not belong to current canvas"
                return false

            # Zone is not changed
            if oldZone.name == newZone
                return false

            # Update data ( and instance、volume、subnet、eni )
            oldZoneName   = oldZone.name
            oldZone.name  = newZone
            resource_type = constant.AWS_RESOURCE_TYPE

            for uid, component of MC.canvas_data.component

                console.log component.type, component.AvailabilityZone, oldZoneName

                if component.type == resource_type.AWS_EC2_Instance
                    placement = component.resource.Placement
                    if placement.AvailabilityZone == oldZoneName
                        placement.AvailabilityZone = newZone

                else if component.resource.AvailabilityZone == oldZoneName

                    if component.type == resource_type.AWS_EBS_Volume ||
                       component.type == resource_type.AWS_VPC_Subnet ||
                       component.type == resource_type.AWS_VPC_NetworkInterface

                        component.resource.AvailabilityZone = newZone
                    else
                        console.log "[Warning] component:", component "has the same AZ, but not changed!!!"

            true
    }

    model = new AZModel()

    return model
