
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSSG
    newNameTmpl : "security-group"

    initialize : () ->
      RuleModel = Design.modelClassForType( constant.RESTYPE.OSSGRULE )
      @get("rules").push( new RuleModel() )
      return

    defaults : ()->
      description : "custom security group"
      rules       : []

    attachSG : (targetModel) ->
      SgAsso = Design.modelClassForType( "OsSgAsso" )
      new SgAsso( targetModel, @ )

    unAttachSG : (targetModel) ->
      SgAsso = Design.modelClassForType( "OsSgAsso" )
      (new SgAsso( targetModel, @ )).remove()

    addRule : ( ruleData )->
      for rule in @get("rules")
        if rule.isEqualToData( ruleData )
          return false

      RuleModel = Design.modelClassForType( constant.RESTYPE.OSSGRULE )
      rule = new RuleModel(ruleData)
      @get("rules").push(rule)
      return rule.id

    getRule : ( id )->
      for rule in @get("rules")
        if rule.id is id
          return rule
      null

    removeRule : ( idOrModel )->
      for r, idx in @get("rules")
        if r is idOrModel or r.id is idOrModel
          @get("rules").splice( idx, 1 )
          break
      return

    getMemberList : () ->
      return _.filter @connectionTargets('OsSgAsso'), (tgt) ->
        return true

    isDefault : () -> @get('name') is 'DefaultSG'

    remove : ()->
      for rule in @get("rules")
        rule.remove()
      ComplexResModel.prototype.remove.apply this, arguments

    serialize : ()->
      if @getMemberList().length
        {
          component :
            name : @get("name")
            type : @type
            uid  : @id
            resource :
              id   : @get("appId")
              name : @get("name")

              description : @get("description")
              rules       : @get("rules")?.map ( rule )-> rule.toJSON()
        }
      else
        null

  }, {

    handleTypes  : constant.RESTYPE.OSSG

    deserialize : ( data, layout_data, resolve )->

      RuleModel = Design.modelClassForType( constant.RESTYPE.OSSGRULE )

      sgModel = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id
        description : data.resource.description
      })

      rules = data.resource.rules.map ( rule )->

        if rule.remote_group_id
          rule.remote_group_id = resolve( MC.extractID( rule.remote_group_id ) )
        rModel = new RuleModel()
        rModel.fromJSON( rule )
        rModel

      if rules.length
        for rule in sgModel.get("rules")
          rule.remove()
        sgModel.set('rules', rules)

      return

    getDefaultSg : ()->
      _.find Model.allObjects(), ( obj )-> obj.isDefault()

    attachDefaultSG : (targetModel) ->
      defaultSg = Model.getDefaultSg()
      SgAsso = Design.modelClassForType('OsSgAsso')
      new SgAsso(defaultSg, targetModel)

  }

  Model
