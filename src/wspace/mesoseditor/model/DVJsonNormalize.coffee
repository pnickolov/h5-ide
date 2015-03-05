
define [ "./DesignMesos"], ( Design )->

  # Change component layout.

  Design.registerDeserializeVisitor ( data, layout_data, version )->

    result_data   = {}
    result_layout = {}

    store = ( component, type )->
      component.__uid = MC.guid()
      component.type  = type

      result_data[ component.__uid ]   = component
      result_layout[ component.__uid ] = layout_data[ component.id ]
      delete layout_data[ component.id ]
      return

    for uid, comp of data
      delete data[uid]
      extractComp comp, store

    for uid, comp of result_data
      data[ uid ] = comp
      layout_data[ uid ] = result_layout[ uid ]
    return

  extractComp = ( comp, store )->
    store( comp, comp.type )

    if comp.type isnt "DOCKER.MARATHON.Group" then return

    for g in comp.groups || []
      g.__parentGroup = comp.__uid
      g.type = "DOCKER.MARATHON.Group"
      extractComp( g, store )

    for g in comp.apps || []
      g.__parentGroup = comp.__uid
      store( g, "DOCKER.MARATHON.App" )

    comp.groups = undefined
    comp.apps   = undefined
    return
