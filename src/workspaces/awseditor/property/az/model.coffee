#############################
#  View Mode for design/property/az
#############################

define [ '../base/model', "Design", 'constant', "CloudResources" ], ( PropertyModel, Design, constant, CloudResources ) ->

    AZModel = PropertyModel.extend {

        init : ( id ) ->

            design = Design.instance()

            az_list = CloudResources( constant.RESTYPE.AZ, Design.instance().region() ).where({category:design.get("region")})

            component = design.component( id )

            if not component or not az_list
                return false

            selectedItemName = component.get("name")

            used_list = {}
            # Get ModelClass of AZ without requring it.
            AZClass = Design.modelClassForType constant.RESTYPE.AZ

            # Get all az components.
            _.each AZClass.allObjects(), ( element )->
                used_list[ element.get("name") ] = true
                null

            possible_list = []
            for az in az_list
                az = az.attributes
                if az.id is selectedItemName or !used_list[az.id]
                    possible_list.push
                        name      : az.id
                        selected  : az.id  is selectedItemName

            @set {
                uid  : id
                name : selectedItemName
                list : possible_list
            }
            null
    }

    new AZModel()
