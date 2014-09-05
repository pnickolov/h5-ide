
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSSERVER
    newNameTmpl : "Server-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id        : @get("appId")
          name      : @get("name")
          flavor    : ""
          image     : ""
          meta      : ""
          NICS      : []
          userdata  : ""
          adminPass : ""
          availabilityZone   : ""
          blockDeviceMapping : []

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSSERVER

    deserialize : ( data, layout_data, resolve )->
      server = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      PortUsage = Design.modelClassForType( "OsPortUsage" )
      for port in data.resource.NICS || []
        port = resolve( MC.extractID( port["port-id"] ) )
        new PortUsage( server, port )

      return
  }

  Model
