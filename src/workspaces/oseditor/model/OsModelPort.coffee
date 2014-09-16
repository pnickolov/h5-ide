
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPORT
    newNameTmpl : "Port-"


    defaults: ()->
      ip : ""
      macAddress : ""

    owner : ()-> @connectionTargets("OsPortUsage")[0]
    isAttached : ()-> !!@owner()

    isVisual : ()-> !@isEmbedded()
    isEmbedded : ()->
      if not @parent() then return false
      @owner() and @owner().embedPort() is @

    attachSG : (sgModel) ->

        SgAsso = Design.modelClassForType( "OsSgAsso" )
        new SgAsso( @, sgModel )

    unAttachSG : (sgModel) ->

        SgAsso = Design.modelClassForType( "OsSgAsso" )
        (new SgAsso( @, sgModel )).remove()

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
      subnet = (@owner() || @).parent()

      {
        layout : @generateLayout()
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id   : @get("appId")
            name : @get("name")

            mac_address     : @get("macAddress")
            security_groups : @connectionTargets("OsSgAsso").map ( sg )-> sg.createRef("id")
            network_id      : subnet.parent().createRef("id")
            device_id       : if @owner() then @owner().createRef("id") else ""
            fixed_ips       : [{
              subnet_id  : subnet.createRef("id")
              ip_address : @get("ip")
            }]
      }

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
        macAddress : data.resource.mac_address

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      SgAsso = Design.modelClassForType( "OsSgAsso" )
      for sg in data.resource.security_groups
        new SgAsso( port, resolve( MC.extractID( sg ) ) )

      return
  }

  Model
