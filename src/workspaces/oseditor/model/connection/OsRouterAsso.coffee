
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ### Router <=> Subnet ###
  ConnectionModel.extend {
    type : "OsRouterAsso"

    portDefs : [
      {
        port1 :
          name : "route"
          type : constant.RESTYPE.OSRT
        port2 :
          name : "route"
          type : constant.RESTYPE.OSSUBNET
      }
    ]
  }


  ### ExtNetwork <=> Router ###
  ConnectionModel.extend {
    type : "OsExtRouterAttach"

    portDefs : [
      {
        port1 :
          name : "router"
          type : constant.RESTYPE.OSEXTNET
        port2 :
          name : "external"
          type : constant.RESTYPE.OSRT
      }
    ]

    # This connection only accept one component ( p1Comp as the router ), the p2Comp is ignore.
    # Since this connection will automatically find the ext network.
    constructor : ( p1Comp, p2Comp, attr, option ) ->
      extNetwork = p1Comp.design().componentsOfType( constant.RESTYPE.OSEXTNET )[0]
      ConnectionModel.call this, p1Comp, extNetwork, attr, option
  }
