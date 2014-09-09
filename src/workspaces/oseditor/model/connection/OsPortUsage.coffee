
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "OsPortUsage"

    portDefs : [
      {
        port1 :
          name : "server"
          type : constant.RESTYPE.OSSERVER
        port2 :
          name : "server"
          type : constant.RESTYPE.OSPORT
      }
    ]

    isVisual : ()->
      server = @getTarget( constant.RESTYPE.OSSERVER )
      server.embedPort() isnt @getTarget( constant.RESTYPE.OSPORT )
  }
