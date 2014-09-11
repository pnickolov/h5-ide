
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
  }
