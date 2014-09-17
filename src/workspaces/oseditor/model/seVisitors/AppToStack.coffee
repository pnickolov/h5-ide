define [ "../DesignOs" ], (Design)->

    # AppToStack is an util function to make sure a JSON is a stack JSON,
    # when serializing.
    Design.registerSerializeVisitor (components, layouts, options)->
        if not options or not options.toStack
            return

    return
