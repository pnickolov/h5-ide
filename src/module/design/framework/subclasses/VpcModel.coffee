
define [ "../GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC

  }

  Model
