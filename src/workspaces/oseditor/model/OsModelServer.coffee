
define [ "ComplexResModel", "constant", "Design", "CloudResources" ], ( ComplexResModel, constant, Design, CloudResources )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSSERVER
    newNameTmpl : "Server-"

    defaults : ()->
      userData         : "User Data Sample"
      meta             : ""
      adminPass        : "12345678"
      keypair          : "$DefaultKeyPair"
      flavorId         : "6"
      availabilityZone : ""
      imageId          : ""
      credential       : "keypair"

    initialize : ( attr, option )->
      option = option || {}
      console.assert( attr.imageId, "Invalid attributes when creating OsModelServer", attr )
      @setImage( attr.imageId )
      @setCredential(attr)

      if option.createByUser
        # Create a port if the server is created by user.
        PortModel = Design.modelClassForType( constant.RESTYPE.OSPORT )
        PortUsage = Design.modelClassForType( "OsPortUsage" )

        newPort = new PortModel({name: @get('name')+"-port"})
        new PortUsage(@, newPort)
      null

    embedPort : ()-> @connectionTargets("OsPortUsage")[0]

    volumes : ()-> @connectionTargets("OsVolumeUsage")

    setCredential: (attr)->
      if attr.keypair
        @.set('credential', "keypair")
      else if attr.adminPass
        @.set('credential', 'adminPass')

    setImage : ( imageId )->
      @set "imageId", imageId
      # Update cached image
      image    = @getImage()
      cached = @get("cachedAmi")
      if image and cached
        cached.os_distro      = image.os_distro
        cached.architecture   = image.architecture
      null

    getImage : ()->
      image = CloudResources( constant.RESTYPE.OSIMAGE, @design().region() ).get( @get("imageId") )
      if image
        image.toJSON()
      else
        null

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id        : @get("appId")
          name      : @get("name")
          flavor    : @get('flavorId')
          image     : @get('imageId')
          meta      : @get('meta')
          NICS      : @connectionTargets( "OsPortUsage" ).map ( port )-> { "port-id" : port.createRef("id") }
          userdata  : @get('userData')
          availabilityZone   : @get('availabilityZone')
          blockDeviceMapping : []

      if @get('credential') is "keypair"
        component.resource.key_name = @get("keypair")
      else
        component.resource.adminPass = @get("adminPass")

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes  : constant.RESTYPE.OSSERVER

    deserialize : ( data, layout_data, resolve )->
      server = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id
        flavorId  : data.resource.flavor
        imageId   : data.resource.image
        adminPass : data.resource.adminPass
        keypair   : data.resource.key_name

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      PortUsage = Design.modelClassForType( "OsPortUsage" )
      for port, idx in data.resource.NICS || []
        port = resolve( MC.extractID( port["port-id"] ) )
        if idx is 0
          # Use server to replace port.
          port.parent().addChild( server )
          port.parent().removeChild( port )
        new PortUsage( server, port )

      return
  }

  Model
