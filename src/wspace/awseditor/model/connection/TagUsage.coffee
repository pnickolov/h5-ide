
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "TagUsage"
    constructor : ( p1Comp, p2Comp, attr, option ) ->
        if p1Comp.type is constant.RESTYPE.VPN
            p1Comp = p1Comp.getResourceModel()
        else if p2Comp.type is constant.RESTYPE.VPN
            p2Comp = p2Comp.getResourceModel()

        ConnectionModel.apply @, arguments
  }
