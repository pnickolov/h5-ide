
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

  }

  Model
