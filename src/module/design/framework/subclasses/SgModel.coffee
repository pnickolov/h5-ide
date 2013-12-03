
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

  }

  Model
