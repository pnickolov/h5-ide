
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSFIP
    newNameTmpl : "FloatIp-"

    serialize : ()->
      port = @connectionTargets("OsFloatIpUsage")[0]
      if not port then return

      extNetworkAry = @design().componentsOfType(constant.RESTYPE.OSEXTNET)
      if extNetworkAry and extNetworkAry.length
        extNetworkId = extNetworkAry[0].getResourceId()

      port_id = port.createRef( if port.type is constant.RESTYPE.OSLISTENER then "port_id" else "id" )

      {
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id : @get("appId")
            fixed_ip_address    : port.createRef("fixed_ips.0.ip_address")
            floating_ip_address : @get("address") or ''
            port_id             : port_id
            floating_network_id : extNetworkId
      }

  }, {

    handleTypes  : constant.RESTYPE.OSFIP

    deserialize : ( data, layout_data, resolve )->
      fip = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        address : data.resource.floating_ip_address
      })

      port = resolve( MC.extractID( data.resource.port_id ) )
      if port
        IpUsage = Design.modelClassForType("OsFloatIpUsage")
        new IpUsage( fip, port )
      return
  }

  Model
