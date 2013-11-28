
define [ "../GroupModel", "constant" ], ( GroupModel, constant )->

  AzModel = GroupModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

  }

  AzModel
