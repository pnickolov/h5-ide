
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPORT
    newNameTmpl : "Port-"

    server : ()-> @connectionTargets("OsPortUsage")[0]

    isEmbedded : ()-> @server() and @server().embedPort() is @
    isVisual   : ()-> !@isEmbedded()

    setFloatingIp : ( hasFip )->
      oldUsage = @connections("OsFloatIpUsage")[0]
      if not hasFip
        if oldUsage then oldUsage.remove()
      else
        if not oldUsage
          Usage = Design.modelClassForType("OsFloatIpUsage")
          new Usage( this )
      return

    getFloatingIp : ()-> @connectionTargets("OsFloatIpUsage")[0]

    serialize : ()->
      subnet = (server || @).parent()

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")

          admin_state_up  : ""
          mac_address     : ""
          fixed_ips       : [{
            subnet_id  : "@{#{subnet.id}.resource.id}"
            ip_address : @get("ip")
          }]
          security_groups : []
          network_id      : ""

      { component : component }

    setIp: (ip)->
      @set "ip", ip

  }, {

    handleTypes  : constant.RESTYPE.OSPORT

    deserialize : ( data, layout_data, resolve )->
      port = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        parent : resolve( MC.extractID( data.resource.fixed_ips[0].subnet_id) )

        ip : data.resource.fixed_ips[0].ip_address

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      SgAsso = Design.modelClassForType( "OsSgAsso" )
      for sg in data.resource.security_groups
        new SgAsso( port, resolve( MC.extractID( sg ) ) )

      return
  }

  Model
