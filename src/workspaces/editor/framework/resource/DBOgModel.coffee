
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
        options       : []

    remove: ->
      _.invoke @connectionTargets( 'OgUsage' ), 'setDefaultOptionGroup'
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
          OptionGroupName       : @get('appId') or ''
          Options               : @get 'options'
          VpcId                 : @getVpcRef()

      { component : component }

  }, {

    handleTypes : constant.RESTYPE.DBOG

    deserialize : ( data, layout_data, resolve ) ->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.OptionGroupName

        createdBy     : data.resource.CreatedBy

        engineName    : data.resource.EngineName
        engineVersion : data.resource.MajorEngineVersion

        description   : data.resource.OptionGroupDescription
        options       : data.resource.Options

      })

  }

  Model

