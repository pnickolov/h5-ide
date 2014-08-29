
define [ "./CanvasView", "constant" ], ( CanvasView, constant )->

  Defination = null

  # BinPack
  # Modified version of https://github.com/jakesgordon/bin-packing
  class GrowingPacker
    constructor : (paddingX, paddingY)->
      @px = paddingX || 0
      @py = paddingY || 0

    fit : (blocks) ->
      len = blocks.length
      @root =
        x: 0
        y: 0
        w: if len > 0 then blocks[0].w + @px else 0
        h: if len > 0 then blocks[0].h + @py else 0

      n = 0
      while n < len
        block = blocks[n]
        w = block.w + @px
        h = block.h + @px
        if node = @findNode(@root, w, h)
          block.fit = @splitNode(node, w, h)
        else
          block.fit = @growNode(w, h)
        n++
      return

    findNode : (root, w, h) ->
      if root.used
        @findNode(root.right, w, h) or @findNode(root.down, w, h)
      else if (w <= root.w) and (h <= root.h)
        root
      else
        null

    splitNode : (node, w, h) ->
      node.used = true
      node.down =
        x: node.x
        y: node.y + h
        w: node.w
        h: node.h - h

      node.right =
        x: node.x + w
        y: node.y
        w: node.w - w
        h: h

      node

    growNode : (w, h) ->
      canGrowDown = (w <= @root.w)
      canGrowRight = (h <= @root.h)
      shouldGrowRight = canGrowRight and (@root.h >= (@root.w + w)) # attempt to keep square-ish by growing right when height is much greater than width
      shouldGrowDown = canGrowDown and (@root.w >= (@root.h + h)) # attempt to keep square-ish by growing down  when width  is much greater than height
      if shouldGrowRight
        @growRight w, h
      else if shouldGrowDown
        @growDown w, h
      else if canGrowRight
        @growRight w, h
      else if canGrowDown
        @growDown w, h
      else # need to ensure sensible root starting size to avoid this happening
        null

    growRight: (w, h) ->
      @root =
        used: true
        x: 0
        y: 0
        w: @root.w + w
        h: @root.h
        down: @root
        right:
          x: @root.w
          y: 0
          w: w
          h: @root.h

      if node = @findNode(@root, w, h)
        @splitNode node, w, h
      else
        null

    growDown: (w, h) ->
      @root =
        used: true
        x: 0
        y: 0
        w: @root.w
        h: @root.h + h
        down:
          x: 0
          y: @root.h
          w: @root.w
          h: h

        right: @root

      if node = @findNode(@root, w, h)
        @splitNode node, w, h
      else
        null

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
      width  : x      || def.width  || 0
      height : height || def.height || 0
    }

  DefaultMethods = {
    GroupMByType : DefaultGroupMethod
    ArrangeHorizontal : DefaultArrangeMethod
    ArrangeVertical : ( children )->
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
        width  : width || def.width  || 0
        height : y     || def.height || 0
      }

    ArrangeBinPack : ( children )->
      if children.length is 0
        return {
          width  : 0
          height : 0
        }
      else if children.length is 1
        children[0].x = children[0].y = 0
        return {
          width  : children[0].width
          height : children[0].height
        }

      chs = children.map ( ch )->
        {
          w    : ch.width
          h    : ch.height
          item : ch
          sign : if ch.width > ch.height then ch.width else ch.height
        }

      chs.sort ( a, b )-> b.sign - a.sign

      def    = Defination[ @type ] || {}
      spaceX = def.spaceX || def.space  || 0
      spaceY = def.spaceY || def.space  || 0

      (new GrowingPacker( spaceX, spaceY )).fit( chs )

      width  = 0
      height = 0
      for ch in chs
        ch.item.x = ch.fit?.x || 0
        ch.item.y = ch.fit?.y || 0
        width  = Math.max( width,  ch.item.x + ch.item.width )
        height = Math.max( height, ch.item.y + ch.item.height )

      {
        width  : width
        height : height
      }
  }

  # Helper
  __GetMethod = ( m )->
    if not m then return null
    if _.isFunction( m ) then return m
    DefaultMethods[ m ]

  # Layout Logics
  buildHierachy = ( item )->
    def = Defination[ item.type ] || {}
    obj =
      component : item
      type      : item.type
      x         : 0
      y         : 0

    if item.children

      obj.children = []
      children = item.children()

      sort = __GetMethod( Defination[ item.type ]?.sortMethod )
      if sort
        children = sort.call item, children

      for ch in children
        if Defination[ch.type].ignore then continue

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

    if item.children and item.children.length
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
    else
      size = def

    item.width  = size.width  || 0
    item.height = size.height || 0
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
        view.applyGeometry( x, y, item.width, item.height, false )
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

    ###
    # 5. Update Line
    ###
    line.update() for uid, line of @__itemLineMap
    return

  buildHierachyPartial = ( item, parentX, parentY )->
    def = Defination[ item.type ] || {}

    obj =
      component : item
      type      : item.type
      x         : Math.max( item.x() - parentX, 0 )
      y         : Math.max( item.y() - parentY, 0 )
      width     : item.width()  || def.width  || 0
      height    : item.height() || def.height || 0

    obj.existing = !!obj.x

    if item.children
      obj.isGroup = true

      obj.children = []
      children = item.children()

      sort = __GetMethod( Defination[ item.type ]?.sortMethod )
      if sort
        children = sort.call item, children

      for ch in children
        d = Defination[ch.type]
        if d.ignore or d.sticky then continue

        obj.children.push buildHierachyPartial( ch, item.x(), item.y() )

    obj

  groupChildrenPartial = ( item )->
    if item.children
      groupChildrenPartial( ch ) for ch in item.children

    # Find out children that already has coordinate
    existings = []
    newitems  = []

    if not item.children
      return

    for ch in item.children
      if ch.x || ch.y
        existings.push ch
      else
        newitems.push ch

    groupMethod   = __GetMethod( Defination[ item.type ]?.groupMethod) || DefaultGroupMethod
    item.children = groupMethod.call( item, newitems )

    if existings.length
      x2 = y2 = 0
      for ch in existings
        x2 = Math.max( x2, ch.x + ch.width )
        y2 = Math.max( y2, ch.y + ch.height )

      item.children.unshift {
        type     : "ExsitingItem"
        children : existings
        x        : 0
        y        : 0
        width    : x2
        height   : y2
      }
    item

  __isOverlap = ( ch1, ch2 )->
    not ( ch1.x >= ch2.x2 or ch1.x2 <= ch2.x or ch1.y >= ch2.y2 or ch1.y2 <= ch2.y )

  arrangeGroupExisting = ( item )->

    needToArrange = false

    for ch in item.children
      oldWidth  = ch.width || 0
      oldHeight = ch.height || 0
      arrangeGroupPartial( ch )
      ch.width  = Math.max( ch.width,  oldWidth )
      ch.height = Math.max( ch.height, oldHeight )

      if ch.isGroup
        needToArrange = true

    if needToArrange
      # 1. Sort array by distance to the origin first.
      for ch in item.children
        ch.manhattan = Math.pow( ch.x, 2 ) + Math.pow( ch.y, 2 )
        if ch.isGroup
          ch.x      -= 1
          ch.y      -= 1
          ch.width  += 2
          ch.height += 2

        ch.x2 = ch.x + ch.width
        ch.y2 = ch.y + ch.height

      item.children.sort ( a, b )-> a.manhattan - b.manhattan

      # 2. Loop through all the item, see if it overlaps with each other
      for ch, i in item.children
        j = i + 1
        while j < item.children.length
          sibling = item.children[ j ]
          if __isOverlap( ch, sibling )
            # Move sibling
            if ch.x2 - sibling.x > ch.y2 - sibling.y
              sibling.y  = ch.y2
              sibling.y2 = ch.y2 + sibling.height
            else
              sibling.x  = ch.x2
              sibling.x2 = ch.x2 + sibling.height
          ++j

      # 3. Restore group's geometry
      for ch in item.children
        if ch.isGroup
          ch.x      += 1
          ch.y      += 1
          ch.width  -= 2
          ch.height -= 2

    oldWidth  = item.width
    oldHeight = item.height
    for ch in item.children
      item.width  = Math.max( ch.x + ch.width,  item.width )
      item.height = Math.max( ch.y + ch.height, item.height )

    item.sizeChanged = oldWidth != item.width || oldHeight != item.height
    return

  arrangeGroupPartial = ( item )->
    def = Defination[ item.type ] || {}

    if not item.children or item.children.length is 0
      item.width  = item.width  || def.width || 0
      item.height = item.height || def.height || 0
      return item

    # First arrange children
    for ch in item.children
      if ch.type is "ExsitingItem"
        arrangeGroupExisting( ch )
      else
        arrangeGroupPartial( ch )

    # Arrange ourself
    if item.children[0].type isnt "ExsitingItem"
      # If the group doesn't have existing items.
      # Then we arrange it like we do in the full-autolayout
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
      return item

    # We have existing children, do it with different approach.
    def    = Defination[ item.type ] || {}
    margin = def.margin || 0

    firstChild = item.children[0]

    if item.children.length is 1
      if firstChild.sizeChanged
        # We don't have newly added children in this group
        item.width  = Math.max( margin + firstChild.width,  item.width )
        item.height = Math.max( margin + firstChild.height, item.height )
      return item

    firstChild.width  -= margin
    firstChild.height -= margin
    size = DefaultMethods.ArrangeBinPack.call item, item.children
    for ch, idx in item.children
      if idx isnt 0
        ch.x += margin
        ch.y += margin
      else
        ch.width  += margin
        ch.height += margin

    item.width  = size.width  + margin * 2
    item.height = size.height + margin * 2
    item

  CanvasView.prototype.autoLayoutPartial = ()->
    Defination = @autoLayoutConfig

    ###
    # 1. Build hierachy
    ###
    svgChildren = @__itemTopLevel.map ( item )-> item.model
    hierachy =
      type     : "SVG"
      children : ()-> svgChildren
      x        : ()-> 0
      y        : ()-> 0
      width    : ()-> 0
      height   : ()-> 0

    hierachy = buildHierachyPartial( hierachy, 0, 0 )

    groupChildrenPartial( hierachy )
    arrangeGroupPartial( hierachy )
    @applyGeometry( hierachy, 0, 0 )
    console.info "Partially autolayout data:", hierachy
    line.update() for uid, line of @__itemLineMap
    return


  {
    DefaultGroupMethod   : DefaultGroupMethod
    DefaultArrangeMethod : DefaultArrangeMethod
  }
