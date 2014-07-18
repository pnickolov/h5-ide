
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
        engineName      : ''
        engineVersion   : ''
        options         : []
        applyImmediately: true

    remove: ->
      _.invoke @connectionTargets( 'OgUsage' ), 'setDefaultOptionGroup'
      ComplexResModel.prototype.remove.apply @, arguments

    serialize : ( options )->
      isRunOrUpdate = options and options.usage and _.contains( ['runStack', 'updateApp'] , options.usage)

      if isRunOrUpdate and not @connections().length
        console.debug( "Option Group is not serialized, because nothing use it." )
        return

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
          ApplyImmediately      : @get 'applyImmediately'
          VpcId                 : @getVpcRef()

      { component : component }

  }, {

    handleTypes : constant.RESTYPE.DBOG

    deserialize : ( data, layout_data, resolve ) ->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.OptionGroupName

        createdBy       : data.resource.CreatedBy

        engineName      : data.resource.EngineName
        engineVersion   : data.resource.MajorEngineVersion

        options         : data.resource.Options
        description     : data.resource.OptionGroupDescription
        applyImmediately: data.resource.ApplyImmediately

      })

  }

  Model

