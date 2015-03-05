
define [ "./DesignMesos"], ( Design )->

  # Change component layout.

  Design.registerDeserializeVisitor ( data, layout_data, version )->
    result = {}
    for uid, comp of data
      extractComp comp, result
    return

  extractComp = ( comp, result )->
    if comp.type isnt "DOCKER.MARATHON.Group"
      result.push comp
      return

    result.push comp
    for g in comp.groups
      g.__parentGroup = comp.id
      extractComp( g, result )

    comp.groups = undefined
    return
