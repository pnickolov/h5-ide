
define [ "../GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

  }

  Model
