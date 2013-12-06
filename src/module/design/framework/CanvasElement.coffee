
define [], ()->

  CanvasElement = ( component )->
    this.coordinate = [ component.x(), component.y() ]
    this.size       = [ component.width(), component.height() ]
    this.id         = component.id
    this.type       = component.type
    this.group      = component.get("group")

    this.parentId   = component.parent()
    this.parentId   = if this.parent then "" else this.parentId.id

    this

  CanvasElement.prototype.isNode  = ()-> !this.group
  CanvasElement.prototype.isGroup = ()-> this.group


  CanvasElement.prototype.element = ()->
    if not this.el
      this.el = $("#" + this.id)

    this.el

  CanvasElement.prototype.resize = ()->
    this.size

  CanvasElement.prototype.position = ()->
    this.coordinate

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
