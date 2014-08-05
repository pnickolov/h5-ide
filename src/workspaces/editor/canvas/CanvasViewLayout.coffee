
define [ "./CanvasView", "constant" ], ( CanvasView, constant )->

  Defination = null

  # Default Group helpers
  DefaultGroupMethod = ( children )->
    groups = []
    for type, childrens of _.groupBy( children, "type" )
      groups.push {
        type     : type + "_group"
        children : childrens
      }
    groups

  # Default Arrange Helpers
  DefaultArrangeMethod = ( children )->
    def   = Defination[ @type ] || {}
    space = def.space  || 0

    x = 0
    height = 0

    for ch in children
      chDef    = Defination[ ch.type ] || {}
      chWidth  = ch.width  || chDef.width || 0
      chHeight = ch.height || chDef.height || 0

      ch.x = x
      ch.y = 0
      if chWidth > 0
        x += chWidth + space

      if chHeight and chHeight > height
        height = chHeight

    if children.length then x -= space

    {
      width  : x || def.width
      height : height || def.height
    }

  DefaultMethods = {
    GroupMByType      : DefaultGroupMethod
    ArrangeHorizontal : DefaultArrangeMethod
    ArrangeVertical   : ( children )->
      def   = Defination[ @type ] || {}
      space = def.space  || 0

      y     = 0
      width = 0

      for ch in children
        chDef    = Defination[ ch.type ] || {}
        chWidth  = ch.width  || chDef.width  || 0
        chHeight = ch.height || chDef.height || 0

        ch.x = 0
        ch.y = y
        if chHeight > 0
          y += chHeight + space

        if chWidth and chWidth > width
          width = chWidth

      if children.length then y -= space

      {
        width  : width || def.width
        height : y || def.height
      }
    ArrangeBinPack : ( children )->
      def   = Defination[ @type ] || {}
      space = def.space  || 0

      y     = 0
      width = 0

      for ch in children
        chDef    = Defination[ ch.type ] || {}
        chWidth  = ch.width  || chDef.width  || 0
        chHeight = ch.height || chDef.height || 0

        ch.x = 0
        ch.y = y
        if chHeight > 0
          y += chHeight + space

        if chWidth and chWidth > width
          width = chWidth

      if children.length then y -= space

      {
        width  : width || def.width
        height : y || def.height
      }
  }

  # Helper
  __GetMethod = ( m )->
    if not m then return null
    if _.isFunction( m ) then return m
    DefaultMethods[ m ]

  # Layout Logics
  buildHierachy = ( item )->
    obj =
      component : item
      type : item.type
      x : 0
      y : 0

    if item.children

      obj.children = []
      children = item.children()

      sort = __GetMethod( Defination[ item.type ]?.sortMethod )
      if sort
        children = sort.call item, children

      for ch in children
        if Defination[ ch.type ]?.ignore then continue

        obj.children.push buildHierachy( ch )

    obj

  groupChildren = ( item )->
    if item.children
      groupChildren( ch ) for ch in item.children

    groupMethod = __GetMethod( Defination[ item.type ]?.groupMethod) || DefaultGroupMethod
    item.children = groupMethod.call item, item.children
    item

  arrangeGroup = ( item )->
    def = Defination[ item.type ] || {}

    if item.children
      for ch in item.children
        arrangeGroup( ch )

      arrangeMethod = __GetMethod( def.arrangeMethod ) || DefaultArrangeMethod
      size = arrangeMethod.call item, item.children

      if def.margin
        size.width  += def.margin * 2
        size.height += def.margin * 2

        for ch in item.children
          ch.x += def.margin
          ch.y += def.margin

      item.width  = size.width
      item.height = size.height
    else
      item.width  = def.width || 0
      item.height = def.height || 0

    item

  CanvasView.prototype.applyGeometry = ( item, parentX, parentY )->
    x = item.x + parentX
    y = item.y + parentY

    # Need to first arrange children, because we need to ensure sticky item's position.
    if item.children
      @applyGeometry( ch, x, y ) for ch in item.children

    if item.component
      view = @getItem( item.component.id )
      if view
        # Special treatment for sticky item.
        if Defination[item.type]?.sticky
          x = -1
          y = -1
        view.applyGeometry( x, y, item.width, item.height )
    return

  CanvasView.prototype.autoLayoutFully = ()->

    Defination = @autoLayoutConfig

    ###
    # 1. Build hierachy
    ###
    svgChildren = @__itemTopLevel.map ( item )-> item.model
    hierachy =
      type     : "SVG"
      children : ()-> svgChildren

    hierachy = buildHierachy( hierachy )

    ###
    # 2. Group children
    ###
    groupChildren( hierachy )

    ###
    # 3. Arrange Groups
    ###
    arrangeGroup( hierachy )

    ###
    # 4. Merge Position Info
    ###
    @applyGeometry( hierachy, 5, 3 )

    console.log hierachy
    return

  {
    DefaultGroupMethod   : DefaultGroupMethod
    DefaultArrangeMethod : DefaultArrangeMethod
  }
