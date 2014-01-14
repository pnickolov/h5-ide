
define [ "Design", "constant" ], ( Design, constant )->

  # ThumbnailShim is an util function to allow Thumbnail generator to work.
  # Because Thumbnail generator needs old format of layout.

  Design.registerSerializeVisitor ( components, layout )->

    nodes  = {}
    groups = {}

    uids = []

    for uid, comp of layout
      if uid is "size" then continue

      model = Design.instance().component( uid )
      if not model then return
      if model.node_group
        groups[ uid ] = comp
      else
        nodes[ uid ] = comp

      uids.push uid

    for uid in uids
      delete layout[ uid ]

    layout.component = {
      node  : nodes
      group : groups
    }
    console.log( layout )
    null

  null

