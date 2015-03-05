
define [ "./DesignMesos"], ( Design )->

  # Change component layout.

  Design.registerSerializeVisitor (components, layouts, options)->
    cache = {}

    for uid, comp of components
      cache[ uid ] = comp

      if comp.__parentGroup
        if comp.type is "DOCKER.MARATHON.Group"
          cache[ comp.__parentGroup ].groups.push comp
        else
          cache[ comp.__parentGroup ].apps.push comp
        delete components[ uid ]

    return

