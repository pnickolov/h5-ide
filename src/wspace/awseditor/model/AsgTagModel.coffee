
define [ "constant", "./TagModel", "Design", "./connection/TagUsage"  ], ( constant, TagModel, Design, TagUsage )->

  AsgTagModel = TagModel.extend {
    type: constant.RESTYPE.ASGTAG
  }, {
    handleTypes : [ constant.RESTYPE.ASGTAG ]
    customTagName: 'AutoScalingCustomTags'
  }

  AsgTagModel
