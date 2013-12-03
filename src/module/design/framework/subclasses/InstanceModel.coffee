
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

  }

  Model
