#############################
#  View Mode for design/property/az
#############################

define [ 'module/design/property/base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    AZModel = PropertyModel.extend {

        reInit : () ->
            @init @get "uid"
            null

        init : ( id ) ->

            az_list   = MC.data.config[ MC.canvas_data.region ]
            component = Design.instance().component( id )

            if not component or not az_list
                return false

            az_name = component.get("name")
            data    =
                uid : id
                name : az_name

            if az_list and az_list.zone
                data.az_list = @possibleAZList( az_list.zone.item, az_name )
            else
                data.az_list = [{
                    name      : az_name
                    selected  : true
                }]

            @set data
            null

        possibleAZList : ( datalist, selectedItemName ) ->
            if !datalist
                return

            used_list = {}
            # Get ModelClass of AZ without requring it.
            AZClass = Design.modelClassForType constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

            # Get all az components.
            _.each AZClass.allObjects(), ( element )->
                used_list[ element.get("name") ] = true
                null

            possible_list = []
            for az in datalist
                if az.zoneName is selectedItemName or !used_list[az.zoneName]
                    possible_list.push
                        name      : az.zoneName
                        selected  : az.zoneName  is selectedItemName

            possible_list

        # setName : ( newZone ) ->
        #     component = Design.instance().component( @get("uid") )

        #     oldName = component.get("name")
        #     component.setName( newZone )
        #     return oldName

        #     # Update data ( and instance、volume、subnet、eni )
        #     oldZoneName   = oldZone.name
        #     oldZone.name  = newZone
        #     resource_type = constant.AWS_RESOURCE_TYPE

        #     for uid, component of MC.canvas_data.component

        #         console.log component.type, component.AvailabilityZone, oldZoneName

        #         if component.type == resource_type.AWS_EC2_Instance
        #             placement = component.resource.Placement
        #             if placement.AvailabilityZone == oldZoneName
        #                 placement.AvailabilityZone = newZone

        #         else if component.type == resource_type.AWS_AutoScaling_Group
        #             azs = component.resource.AvailabilityZones.join(",")
        #             if azs.indexOf( oldZoneName ) isnt -1
        #                 azs = azs.replace oldZoneName, newZone
        #                 component.resource.AvailabilityZones = azs.split(",")

        #         else if component.type == resource_type.AWS_ELB
        #             idx = component.resource.AvailabilityZones.indexOf oldZoneName
        #             if idx != -1
        #                 component.resource.AvailabilityZones.splice idx, 1, newZone

        #         else if component.resource.AvailabilityZone == oldZoneName

        #             if component.type == resource_type.AWS_EBS_Volume ||
        #                component.type == resource_type.AWS_VPC_Subnet ||
        #                component.type == resource_type.AWS_VPC_NetworkInterface

        #                 component.resource.AvailabilityZone = newZone
        #             else
        #                 console.log "[Warning] component:", component "has the same AZ, but not changed!!!"

        #     oldZoneName
    }

    new AZModel()
