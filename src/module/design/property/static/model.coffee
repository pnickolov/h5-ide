#############################
#  View Mode for design/property/vgw
#############################

define [ "../base/model", "constant" ], ( PropertyModel, constant ) ->

    StaticModel = PropertyModel.extend {

      init : ( id ) ->

        component = MC.canvas_data.component[ id ]

        isIGW = component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

        @set "isIGW", isIGW
        @set "id", id

        @set "readOnly", @isApp

        appData = MC.data.resource_list[ MC.canvas_data.region ]

        if isIGW
          data = appData[ component.resource.InternetGatewayId ]
          @set "id", component.resource.InternetGatewayId
          if data and data.attachmentSet and data.attachmentSet.item.length
            @set "state", data.attachmentSet.item[0].state
            vpcId = data.attachmentSet.item[0].vpcId

        else
          data = appData[ component.resource.VpnGatewayId ]
          @set "type", data.type
          @set "id", component.resource.VpnGatewayId
          if data and data.attachments and data.attachments.item.length
            @set "state", data.attachments.item[0].state
            vpcId = data.attachments.item[0].vpcId

        vpc = appData[ vpcId ]
        if vpc
          vpcId += "(#{vpc.cidrBlock})"
          @set "vpc", vpcId

        null
    }

    new StaticModel()
