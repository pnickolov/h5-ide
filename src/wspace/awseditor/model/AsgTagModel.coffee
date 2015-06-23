
define [ "constant", "./TagModel", "Design", "./connection/TagUsage"  ], ( constant, TagModel, Design, TagUsage )->
  TagItem = TagModel.TagItem

  AsgTagModel = TagModel.extend {
    type: constant.RESTYPE.ASGTAG

  }, {
    handleTypes : [ constant.RESTYPE.ASGTAG ]
  }

  AsgTagModel
