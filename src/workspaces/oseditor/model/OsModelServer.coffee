
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSSERVER
    newNameTmpl : "Server-"

    #    Server sample json
    #    =====================
    #    "server-id": {
    #      "type": "OS::Nova::Server",
    #      "uid": "server-id",
    #      "resource": {
    #        "name": "helloworldserver",
    #        "flavor": "10",
    #        "image": "03f66db6-a74f-40b5-9933-4a19352083da",
    #        "meta": "",
    #        "userdata": "",
    #        "availabilityZone": "",
    #        "blockDeviceMapping" :[],
    #        "key_name": "testkp",
    #        "NICS":[
    #          {
    #            "port-id": "@{port-id.resource.id}"
    #          }
    #        ],
    #        "adminPass" : "12345678",
    #        "id" : ""
    #      }
    #    }

    defaults:
      userData: ""
      meta: ""
      NICS: []
      adminPass: "xxxxxx"
      key_name: "Default-KP"
      blockDeviceMapping: []
      flavor_id: "10"
      availabilityZone: ""
      image: ""

    embedPort : ()-> @connectionTargets("OsPortUsage")[0]

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id        : @get("appId")
          name      : @get("name")
          flavor    : @get('flavor_id')
          image     : @get('image')
          meta      : @get('meta')
          NICS      : @get('NICS')
          userdata  : @get('userData')
          adminPass : @get('adminPass')
          availabilityZone   : @get('availabilityZone')
          blockDeviceMapping : @get('blockDeviceMapping')

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
