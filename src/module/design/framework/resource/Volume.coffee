
define [ "../ComplexResModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

  }, {
    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume ]

    deserialize : ( data, layout_data, resolve )->
      null
  }

  Model
