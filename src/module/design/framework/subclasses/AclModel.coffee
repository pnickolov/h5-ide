
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant )->

  Model = ResourceModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

  }

  Model
