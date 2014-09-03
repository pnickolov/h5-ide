
define [ "ComplexResModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPOOL
    newNameTmpl : "Pool-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")
          protocol         : ""
          lb_algorithm     : ""
          subnet_id        : ""
          healthmonitor_id : ""
          member           : []

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSPOOL

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
