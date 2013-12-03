
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

  }

  Model
