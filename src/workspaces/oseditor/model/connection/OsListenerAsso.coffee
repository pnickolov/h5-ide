
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "OsListenerAsso"

    portDefs : [
      {
        port1 :
          name : "listener"
          type : constant.RESTYPE.OSLISTENER
        port2 :
          name : "listener"
          type : constant.RESTYPE.OSPOOL
      }
    ]
  }
