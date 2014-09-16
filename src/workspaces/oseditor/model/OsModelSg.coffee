
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSSG
    newNameTmpl : "SecurityGroup-"

    serialize : ()->
      {
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id   : @get("appId")
            name : @get("name")

            description : @get("description")
            rules       : @get("rules").map ( rule )-> rule.toJSON()
      }

  }, {

    handleTypes  : constant.RESTYPE.OSSG

    deserialize : ( data, layout_data, resolve )->

      RuleModel = Design.modelClassForType( constant.RESTYPE.OSSGRULE )

      new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id
        description : data.resource.description
        rules : data.rules.map ( rule )->
          if rule.remote_group_id
            rule.remote_group_id = resolve( MC.extractID( rule.remote_group_id ) )
            rModel = new RuleModel()
            rModel.fromJSON( rule )
            rModel
      })
      return
  }

  Model
