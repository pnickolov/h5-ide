
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  # This model is used to allow creation of listener and pool at the same time
  # And it has no other usage.

  ComplexResModel.extend {
    type : constant.RESTYPE.OSELB
    serialize : ()->
  }, {
    handleTypes  : constant.RESTYPE.OSELB
    deserialize : ()->
  }
