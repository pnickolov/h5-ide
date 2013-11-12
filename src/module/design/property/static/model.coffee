#############################
#  View Mode for design/property/vgw
#############################

define [ "../base/model", "constant" ], ( PropertyModel, constant ) ->

    StaticModel = PropertyModel.extend {

      init : ( id ) ->

        component = MC.canvas_data.component[ id ]

        @set "isIGW", component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
        @set "id", id
    }

    new StaticModel()
