
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

      {
        port1 :
          name : "listener"
          type : constant.RESTYPE.OSLISTENER
        port2 :
          name : "listener"
          type : constant.RESTYPE.OSPORT
      }
    ]

    isVisual : ()->
      server = @getTarget( constant.RESTYPE.OSSERVER )
      server and server.embedPort() isnt @getTarget( constant.RESTYPE.OSPORT )

    remove : ( option )->
      ConnectionModel.prototype.remove.call this, option

      server = @getTarget( constant.RESTYPE.OSSERVER )
      port   = @getTarget( constant.RESTYPE.OSPORT )
      if server.isRemoved() and server.embedPort() is port
        port.remove()

      return

  }
