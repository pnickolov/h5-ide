
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
    newNameTmpl : "custom-sg-"

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

  }

  Model
