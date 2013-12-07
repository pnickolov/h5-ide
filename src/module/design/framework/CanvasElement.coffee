
define [ "./CanvasManager" ], ( CanvasManager )->

  ###
  CanvasElement is intent to be an adaptor for MC.canvas.js to use ResourceModel.
  But in the future, this class can be upgrade to ResourceModel's view on canvas.
  ###

  CanvasElement = ( component, quick )->

    this.id = component.id

    if quick isnt true
      this.coordinate = [ component.x(), component.y() ]
      this.size       = [ component.width(), component.height() ]
      this.type       = component.type
      this.group      = component.get("group")

      this.parentId   = component.parent()
      this.parentId   = if this.parent then "" else this.parentId.id

    this

  CanvasElement.prototype.isNode  = ()-> !this.group
  CanvasElement.prototype.isGroup = ()-> this.group


  CanvasElement.prototype.element = ()->
    if not this.el
      this.el = $( document.getElementById( this.id ) )

    this.el

  CanvasElement.prototype.resize = ( w, h )->
    if w is undefined
      return this.size

    CanvasManager.resize( this.id, w, h )
    null


  CanvasElement.prototype.position = ( x, y )->
    if x is undefined
      return this.coordinate

    CanvasManager.move( this.id, x, y )
    null


  CanvasElement.prototype.offset = ()->
    {
      width  : this.size[0]
      height : this.size[1]
      left   : this.coordinate[0]
      top    : this.coordinate[1]
    }

  CanvasElement.prototype.port = ()->
    if not this.ports
      this.ports = _.map this.element().children(".port"), ( el )->
        el.getAttribute("data-name")

    this.ports

  CanvasElement.prototype.remove = ()->

  CanvasElement.prototype.select = ()->

  CanvasElement.prototype.show = ()->

  CanvasElement.prototype.hide = ()->

  CanvasElement.prototype.hover = ()->
    comp = Design.instance().component( this.id )
    connections = comp.connections()

    for cn in connections
      el = document.getElementById( cn.id )
      if not el
        continue

      klass = el.getAttribute("class")

      if not klass.match(/\bview-hover\b/)
        el.setAttribute("class", klass + " view-hover")


  CanvasElement.prototype.hoverOut = ()->
    comp = Design.instance().component( this.id )
    connections = comp.connections()

    for cn in connections
      el = document.getElementById( cn.id )
      if not el
        continue

      klass    = el.getAttribute("class")
      newKlass = $.trim( klass.replace( /\s?view-hover/g, "" ) )

      if klass != newKlass
        el.setAttribute("class", newKlass)

    null

  CanvasElement.prototype.parent  = ()->
    if this.parent is undefined
      this.parent = if this.parentId then new CanvasElement( this.parentId ) else null

    this.parent

  CanvasElement.prototype.children = ()->
    self = Design.instance().component( this.id )
    if self.children
      _.map self.children(), ( c )->
        new CanvasElement( c )
    else
      []

  CanvasElement.prototype.updateResizer = ()->

  CanvasElement
