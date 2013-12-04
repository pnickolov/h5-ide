
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_ELB

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_ELB

  }

  Model
