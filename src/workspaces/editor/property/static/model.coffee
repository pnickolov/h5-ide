#############################
#  View Mode for design/property/vgw
#############################

define [ "../base/model", "Design", "constant", 'CloudResources' ], ( PropertyModel, Design, constant, CloudResources ) ->

    StaticModel = PropertyModel.extend {

      init : ( id ) ->

        component = Design.instance().component( id )

        isIGW = component.type is constant.RESTYPE.IGW
        @set "isIGW", isIGW

        if @isApp

          @set "readOnly", true

          appId   = component.get("appId")

          data = CloudResources(component.type, Design.instance().region()).get(appId)?.toJSON()

        if data
          if data.attachments and data.attachments.length
            data.attachment_state = data.attachments[0].state
          else if data.attachmentSet and data.attachmentSet.length
            data.attachment_state = data.attachmentSet[0].state
          @set data
          @set 'appId', data.id

        null
    }

    new StaticModel()
