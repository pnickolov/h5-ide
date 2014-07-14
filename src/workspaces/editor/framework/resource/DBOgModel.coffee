
define [
  "../ComplexResModel"
  "Design"
  "constant"
], ( ComplexResModel, Design, constant ) ->

  Model = ComplexResModel.extend {

    newNameTmpl : "option-group-"

    type : constant.RESTYPE.DBOG

    isVisual : () -> false

    defaults : () ->

        engineName    : ''
        engineVersion : ''
        ogDescription : ''
        ogName        : ''
        options       : []

    remove: ->
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
          OptionGroupDescription: @get 'ogDescription'
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

        ogDescription : data.resource.OptionGroupDescription
        ogName        : data.resource.OptionGroupName
        options       : data.resource.Options

      })

  }

  Model

