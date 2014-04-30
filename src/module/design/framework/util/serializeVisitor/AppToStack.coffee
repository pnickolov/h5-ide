
define [ "Design" ], ( Design )->

  # AppToStack is an util function to make sure a JSON is a stack JSON,
  # when serializing.

  Design.registerSerializeVisitor ( components, layouts, options )->

    if not options or not options.toStack
      return

    # TODO : Remove everything that's not necessary in stack JSON. ( No need to return, just modifiy components and layouts )


  null

