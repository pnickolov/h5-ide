
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

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
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
