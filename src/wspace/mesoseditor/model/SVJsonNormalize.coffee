
define [ "./DesignMesos"], ( Design )->

  # Change component layout.

  Design.registerSerializeVisitor (components, layouts, options)->
    cache = {}

    for uid, comp of components
      cache[ uid ] = comp
      layout = layouts[ comp.uid ]

      delete comp.uid

      if layout.groupUId
        parent = cache[ layout.groupUId ]
        if comp.type is "DOCKER.MARATHON.Group"
          delete comp.type
          (parent.groups || parent.groups = []).push comp
        else
          (parent.apps || parent.apps = []).push comp

        delete components[ uid ]

    return

