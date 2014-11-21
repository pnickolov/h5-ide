
define [ "ConnectionModel", "constant" ], ( ConnectionModel, constant )->

  ### Router <=> Subnet ###
  ConnectionModel.extend {
    type : "OsRouterAsso"
    oneToMany : constant.RESTYPE.OSRT

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

    initialize : ()->
      rt = @getTarget( constant.RESTYPE.OSRT )
      @listenTo rt, "change:extNetworkId", @onRtPublicityChanged

      @getTarget( constant.RESTYPE.OSSUBNET ).set "public", rt.isPublic()
      return

    remove : ()->
      subnet = @getTarget( constant.RESTYPE.OSSUBNET )

      res = ConnectionModel.prototype.remove.apply this, arguments

      subnet.set "public", false
      return res

    onRtPublicityChanged : ()->
      @getTarget( constant.RESTYPE.OSSUBNET ).set "public", @getTarget(constant.RESTYPE.OSRT).isPublic()
      return

  }
