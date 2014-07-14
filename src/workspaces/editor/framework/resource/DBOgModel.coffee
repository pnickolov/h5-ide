
define [
  "../ResourceModel"
  "Design"
  "constant"
], ( ResourceModel, Design, constant ) ->

  Model = ResourceModel.extend {

    newNameTmpl : "option-group-"

    type : constant.RESTYPE.DBOG

    defaults : () ->

        engineName    : ''
        engineVersion : ''
        ogDescription : ''
        ogName        : ''
        options       : []

    serialize : ()->
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          EngineName            : @get 'engineName'
          MajorEngineVersion    : @get 'engineVersion'
          OptionGroupDescription: @get 'ogDescription'
          OptionGroupName       : @get 'ogName'
          Options               : @get 'options'
          VpcId                 : vpc.createRef( "VpcId" )

      { component : component }

  }, {

    handleTypes : constant.RESTYPE.DBOG

    deserialize : ( data, layout_data, resolve ) ->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.CreatedBy

        engineName    : data.resource.EngineName
        engineVersion : data.resource.MajorEngineVersion

        ogDescription : data.resource.OptionGroupDescription
        ogName        : data.resource.OptionGroupName
        options       : data.resource.Options

      })

  }

  Model

