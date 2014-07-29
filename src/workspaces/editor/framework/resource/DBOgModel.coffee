
define [
  "../ComplexResModel"
  "Design"
  "constant"
], ( ComplexResModel, Design, constant ) ->

  Model = ComplexResModel.extend {

    newNameTmpl : "-og"

    type : constant.RESTYPE.DBOG

    isDefault: -> !!@get 'default'

    isVisual : () -> false

    initialize: ( attributes, option )->

      return if @isDefault()

      if not @get 'description'

        # set new name
        typeName = @engineType()
        mainVersion = @get('engineVersion').replace(/\./g, '-')
        @set('name', typeName + mainVersion + @get('name'))

        # set new description
        @set 'description', "custom option group for #{@get('engineName')} #{@get('engineVersion')}"

      null

    defaults : () ->
        engineName      : ''
        engineVersion   : ''
        options         : []
        applyImmediately: true

    # mysql, postgresql, oracle, sqlserver
    engineType: ->
      engine = @get 'engineName'
      switch
        when engine is 'mysql'
          return 'mysql'
        when engine is 'postgresql'
          return 'postgresql'
        when engine in ['oracle-ee', 'oracle-se', 'oracle-se1']
          return 'oracle'
        when engine in ['sqlserver-ee', 'sqlserver-ex', 'sqlserver-se', 'sqlserver-web']
          return 'sqlserver'

    remove: ->
      _.invoke @connectionTargets( 'OgUsage' ), 'setDefaultOptionGroup'
      ComplexResModel.prototype.remove.apply @, arguments

    createRef: ->
      if @isDefault()
        @get 'name'
      else
        ComplexResModel.prototype.createRef.apply @, arguments

    serialize : ( options )->
      if @isDefault() then return # Default OG don't have component.

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

