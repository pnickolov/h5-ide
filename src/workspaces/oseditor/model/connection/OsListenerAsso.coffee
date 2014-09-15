
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

    isRemovable : ()-> false

    remove : ()->
      ConnectionModel.prototype.remove.apply this, arguments

      listener = @getTarget( constant.RESTYPE.OSLISTENER )
      pool     = @getTarget( constant.RESTYPE.OSPOOL )

      if listener.isRemoved() and not pool.isRemoved() then pool.remove()
      if pool.isRemoved() and not listener.isRemoved() then listener.remove()

      return
  }
