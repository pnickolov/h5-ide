
define [ "ConnectionModel", "constant", "Design" ], ( ConnectionModel, constant, Design )->

  ConnectionModel.extend {
    type : "OsFloatIpUsage"

    constructor : ( p1comp, p2comp, attr, options )->

      if not p2comp and p1comp.type isnt constant.RESTYPE.OSFIP
        FloatIpModel = Design.modelClassForType( constant.RESTYPE.OSFIP )
        p2Comp = new FloatIpModel()

      ConnectionModel.call this, p1comp, p2Comp, attr, options
  }
