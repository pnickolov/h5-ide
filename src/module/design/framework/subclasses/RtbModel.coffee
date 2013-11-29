
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

  }

  Model
