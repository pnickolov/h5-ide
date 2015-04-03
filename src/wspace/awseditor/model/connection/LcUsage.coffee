
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ConnectionModel.extend {
    type : "LcUsage"

    remove : ()->
      lc = @getOtherTarget constant.RESTYPE.ASG

      ConnectionModel.prototype.remove.apply this, arguments

      if lc.connections("LcUsage").length is 0
        lc.remove()
      return
  }
