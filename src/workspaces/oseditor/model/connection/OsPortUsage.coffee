
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "OsPortUsage"

    portDefs : [
      {
        port1 :
          name : "server"
          type : constant.RESTYPE.OSSERVER
        port2 :
          name : "port"
          type : constant.RESTYPE.OSPORT
      }
    ]
  }
