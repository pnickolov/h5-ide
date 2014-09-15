
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "OsVolumeUsage"

    initialize : ()->
      volume = @getTarget( constant.RESTYPE.OSVOL )
      for usage in volume.connections( "OsVolumeUsage" )
        if usage isnt @
          usage.remove()

      return

    remove : ( option )->
      ConnectionModel.prototype.remove.call this, option

      if @getTarget( constant.RESTYPE.OSSERVER ).isRemoved()
        @getTarget( constant.RESTYPE.OSVOL ).remove()

      return
  }
