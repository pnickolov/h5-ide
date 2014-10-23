
define [ "../DesignOs", "constant" ], ( Design, constant )->

    # AppToStack is an util function to make sure a JSON is a stack JSON,
    # when serializing.
    Design.registerSerializeVisitor (components, layouts, options)->
      if not options or not options.toStack
          return

      for uid, comp of components
        if comp.resource.hasOwnProperty( "id" )
          comp.resource.id = ""

        switch comp.type
          when constant.RESTYPE.OSPOOL
            for member in comp.resource.member || []
              member.id = ""

          when constant.RESTYPE.OSSG
            for rule in comp.resource.rules || []
              rule.id = ""

          when constant.RESTYPE.OSLISTENER
            comp.resource.port_id = ""

      return
    return
