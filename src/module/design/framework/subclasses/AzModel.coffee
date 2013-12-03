
define [ "../GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

  }

  Model
