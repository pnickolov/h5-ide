#############################
#  View Mode for design/property/az
#############################

define [ 'module/design/property/base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    AZModel = PropertyModel.extend {

        reInit : () ->
            @init @get "uid"
            null

        init : ( id ) ->

            az_list   = MC.data.config[ Design.instance().region() ]
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
            AZClass = Design.modelClassForType constant.RESTYPE.AZ

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
    }

    new AZModel()
