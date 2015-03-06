
define [ "constant",
         "GroupModel",
         "./MarathonDepIn",
         "i18n!/nls/lang.js"
], ( constant, GroupModel, MarathonDepIn, lang )->

  Model = GroupModel.extend {

    type    : constant.RESTYPE.MRTHGROUP
    newNameTmpl : "group"

    path : ()->
      path = []
      t = @
      while t
        path.unshift( t.get("name") )
        t = t.parent()
      ("/" + path.join("/")).replace(/\/+/g,"/")

    serialize : ()->

      groups = []
      apps   = []

      for ch in @children()
        if ch.type is constant.RESTYPE.MRTHGROUP
          groups.push ch.id
        else
          apps.push ch.id

      component =
        uid      : @id
        type     : @type
        toplevel : !@parent()
        resource :
          id : @get("name")

      if groups.length then component.resource.groups = groups
      if apps.length   then component.resource.apps   = apps

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.MRTHGROUP

    deserialize : ( data, layout_data, resolve )->

      new Model {

        id    : data.uid
        name  : data.resource.id
        parent : if layout_data.groupUId then resolve( layout_data.groupUId ) else null

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]

      }

      null

    postDeserialize : ( data, layout_data )->
      for dep in data.resource.dependencies || []
        new MarathonDepIn( Design.instance().component(data.uid), dep )

      return
  }

  Model
