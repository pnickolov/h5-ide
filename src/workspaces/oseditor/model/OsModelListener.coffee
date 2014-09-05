
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSLISTENER
    newNameTmpl : "Listener-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")
          default_pool_id  : ""
          description      : ""
          connection_limit : ""
          protocol         : ""
          protocol_port    : ""
          admin_state_up   : ""
          load_balancer_id : ""


      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSLISTENER

    deserialize : ( data, layout_data, resolve )->
      listener = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        parent : resolve( MC.extractID( data.resource.subnet_id ) )
        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
      })

      Asso = Design.modelClassForType( "OsListenerAsso" )
      new Asso( listener, resolve(MC.extractID( data.resource.pool_id )) )
      return
  }

  Model
