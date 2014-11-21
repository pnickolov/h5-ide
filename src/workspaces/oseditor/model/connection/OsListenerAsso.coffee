
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "OsListenerAsso"

    portDefs : [
      {
        port1 :
          name : "elb"
          type : constant.RESTYPE.OSLISTENER
        port2 :
          name : "elb"
          type : constant.RESTYPE.OSPOOL
      }
    ]

    constructor : ( p1Comp, p2Comp )->
      reason = {reason:@}
      asso = p1Comp.connections( "OsListenerAsso" )[0]
      if asso then asso.remove( reason )
      asso = p2Comp.connections( "OsListenerAsso" )[0]
      if asso then asso.remove( reason )
      ConnectionModel.apply this, arguments

    isRemovable : ()-> error: 'Listener must keep connected to Pool'

    remove : ( reason )->
      ConnectionModel.prototype.remove.apply this, arguments

      if reason and reason.reason and reason.reason.type is "OsListenerAsso"
        return

      listener = @getTarget( constant.RESTYPE.OSLISTENER )
      pool     = @getTarget( constant.RESTYPE.OSPOOL )

      if listener.isRemoved() and not pool.isRemoved() then pool.remove()
      if pool.isRemoved() and not listener.isRemoved() then listener.remove()

      return
  }
