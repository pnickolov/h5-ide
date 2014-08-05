
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
      width  : x || def.width
      height : height || def.height
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
        width  : width || def.width
        height : y || def.height
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
          width  : children[0].height
          height : children[0].width
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
