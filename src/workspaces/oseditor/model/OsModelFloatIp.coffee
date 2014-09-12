
define [ "ResourceModel", "constant", "Design" ], ( ResourceModel, constant, Design )->

  Model = ResourceModel.extend {

    type : constant.RESTYPE.OSFIP
    newNameTmpl : "FloatIp-"

    serialize : ()->
      port = @connectionTargets("OsFloatIpUsage")[0]
      if not port then return

      {
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id : @get("appId")
            fixed_ip_address    : "@{#{port.id}.resource.fixed_ips.0.ip_address}"
            floating_ip_address : @get("address")
            port_id             : "@{#{port.id}.resource.id}"
            floating_network_id : @design().componentsOfType( constant.RESTYPE.OSEXTNET ).getResourceId()
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
