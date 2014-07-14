
define [
  "../ComplexResModel"
  "Design"
  "constant"
], ( ComplexResModel, Design, constant ) ->

  Model = ComplexResModel.extend {

    newNameTmpl : "option-group-"

    type : constant.RESTYPE.DBOG

    isVisual : () -> false

    initialize: ( attributes, option )->
      if not @get 'description'
        @set 'description', "#{@get('name')} default description"

      null

    defaults : () ->
        engineName    : ''
        engineVersion : ''
        ogName        : ''
        options       : []

    remove: ->
      _.invoke @connectionTargets( 'OgUsage' ), 'setDefaultOption'
      ComplexResModel.prototype.remove.apply @, arguments

    serialize : ()->
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CreatedBy             : @get('createdBy') or ''
          EngineName            : @get 'engineName'
          MajorEngineVersion    : @get 'engineVersion'
          OptionGroupDescription: @get 'description'
          OptionGroupName       : @get 'ogName'
          Options               : @get 'options'
          VpcId                 : @getVpcRef()

      { component : component }

  }, {

    handleTypes : constant.RESTYPE.DBOG

    deserialize : ( data, layout_data, resolve ) ->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.CreatedBy

        createdBy     : data.resource.CreatedBy

        engineName    : data.resource.EngineName
        engineVersion : data.resource.MajorEngineVersion

        description   : data.resource.OptionGroupDescription
        ogName        : data.resource.OptionGroupName
        options       : data.resource.Options

      })

  }

  Model

