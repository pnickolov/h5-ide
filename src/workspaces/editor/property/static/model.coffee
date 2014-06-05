#############################
#  View Mode for design/property/vgw
#############################

define [ "../base/model", "Design", "constant" ], ( PropertyModel, Design, constant ) ->

    StaticModel = PropertyModel.extend {

      init : ( id ) ->

        component = Design.instance().component( id )

        isIGW = component.type is constant.RESTYPE.IGW
        @set "isIGW", isIGW

        if @isApp

          @set "readOnly", true

          appData = MC.data.resource_list[ Design.instance().region() ]
          appId   = component.get("appId")

          data    = appData[ appId ]

          if data
            if isIGW
              if data.attachmentSet and data.attachmentSet.item.length
                item = data.attachmentSet.item[0]
            else
              item = data
            #else if data.attachments and data.attachments.item.length
            #  item = data.attachments.item[0]

          if item
            if item.attachments and item.attachments.item and item.attachments.item.length
              #vgw
              @set "state", item.state
              @set "attachment_state", item.attachments.item[0].state
              vpcId = item.attachments.item[0].vpcId
            else
              #igw
              @set "state", item.state
              vpcId = item.vpcId
          else
            @set "state", "unavailable"

          vpc = appData[ vpcId ]
          if vpc then vpcId += " (#{vpc.cidrBlock})"

          @set "id", id
          @set "appId", component.get("appId")
          @set "vpc", vpcId

        null
    }

    new StaticModel()
