
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

    initialize : ()->
      rt = @getTarget( constant.RESTYPE.OSRT )
      @listenTo rt, "change:public", @onRtPublicityChanged

      @getTarget( constant.RESTYPE.OSSUBNET ).set "public", rt.get("public")
      return

    remove : ()->
      subnet = @getTarget( constant.RESTYPE.OSSUBNET )

      res = ConnectionModel.prototype.remove.apply this, arguments

      subnet.set "public", false
      return res

    onRtPublicityChanged : ()->
      @getTarget( constant.RESTYPE.OSSUBNET ).set "public", @getTarget(constant.RESTYPE.OSRT).get("public")
      return

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
