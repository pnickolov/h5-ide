
define [ "./DesignMesos"], ( Design )->

  # Change component layout.

  Design.registerSerializeVisitor (components, layouts, options)->
    result = {}

    for uid, comp of components
      if comp.__parentGroup
        data[ comp.__parentGroup ].groups.push comp
        delete components[ uid ]

    return

