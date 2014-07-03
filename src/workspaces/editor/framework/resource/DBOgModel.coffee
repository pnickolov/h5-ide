
define [ "../ResourceModel", "Design", "constant" ], ( ResourceModel, Design, constant )->

  Model = ResourceModel.extend {


    newNameTmpl : "option-group-"

    type : constant.RESTYPE.DBOG

    serialize : ()->
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


      { component : component }

  }, {

    handleTypes : constant.RESTYPE.CGW

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

