
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "OsPoolMembership"

    portDefs : [
      {
        port1 :
          name : "pool"
          type : constant.RESTYPE.OSPOOL
        port2 :
          name : "pool"
          type : constant.RESTYPE.OSPORT
      }
      {
        port1 :
          name : "pool"
          type : constant.RESTYPE.OSPOOL
        port2 :
          name : "pool"
          type : constant.RESTYPE.OSSERVER
      }
    ]

    constructor : ( p1Comp, p2Comp, attr, option )->
      if p1Comp.type is constant.RESTYPE.OSPORT
        port = p1Comp
        pool = p2Comp
      else if p2Comp.type is constant.RESTYPE.OSPORT
        port = p2Comp
        pool = p1Comp

      if port and port.isEmbedded()
        p1Comp = port.server()
        p2Comp = pool

      ConnectionModel.call this, p1Comp, p2Comp, attr, option

  }
