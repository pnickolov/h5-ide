
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

      this.nodeType   = if component.node_group is true then "group" else if component.node_line then "line" else "node"

      this.parentId   = component.parent()
      this.parentId   = if this.parent then "" else this.parentId.id

    this

  CanvasElement.prototype.element = ()->
    if not this.el
      this.el = document.getElementById( this.id )

    this.el

  CanvasElement.prototype.$element = ()->
    if not this.$el
      this.$el = $( document.getElementById( this.id ) )

    this.$el

  CanvasElement.prototype.resize = ( w, h )->
    if w is undefined
      return this.size

    if this.nodeType is "group"
      this.size[0] = w
      this.size[1] = h
      CanvasManager.resize( this.id, w, h )
    null


  CanvasElement.prototype.position = ( x, y )->
    if x is undefined
      return this.coordinate

    this.coordinate[0] = x
    this.coordinate[1] = y
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
      this.ports = _.map this.$element().children(".port"), ( el )->
        el.getAttribute("data-name")

    this.ports

  CanvasElement.prototype.remove = ()->
    comp = Design.instance().component( this.id )
    res  = comp.isRemovable()

    if _.isString( res )
      # Confirmation
      template = MC.template.canvasOpConfirm {
        operation : sprintf lang.ide.CVS_CFM_DEL, comp.get("name")
        content   : res
        color     : "red"
        proceed   : lang.ide.CFM_BTN_DELETE
        cancel    : lang.ide.CFM_BTN_CANCEL
      }
      modal template, true
      theID = this.id
      $("#canvas-op-confirm").one "click", ()->
        comp = Design.instance().component( theID )
        if comp
          comp.remove()

    else if res.error
      # Error
      notification "error", res.error

    else if res is true
      # Do remove
      comp.remove()
      return true

    return false

  CanvasElement.prototype.select = ()->
    # Remove old selected
    $allwarp = $(document.getElementById("group_layer")).children().add( document.getElementById("line_layer") ).add( document.getElementById("node_layer") )
    DesignManager.removeClass $allwarp.children(".selected")[0], "selected"

    # Added selected to this.element
    DesignManager.addClass this.element(), "selected"
    true

  CanvasElement.prototype.show = ()->
    CanvasManager.toggle this.$element(), true
    null

  CanvasElement.prototype.hide = ()->
    CanvasManager.toggle this.$element(), false
    null

  CanvasElement.prototype.hover = ()->
    comp = Design.instance().component( this.id )
    connections = comp.connections()

    for cn in connections
      el = document.getElementById( cn.id )
      if not el
        continue

      CanvasManager.addClass( el, "view-hover" )
    null

  CanvasElement.prototype.hoverOut = ()->
    comp = Design.instance().component( this.id )
    connections = comp.connections()

    for cn in connections
      el = document.getElementById( cn.id )
      if not el
        continue

      CanvasManager.removeClass( el, "view-hover" )
    null

  CanvasElement.prototype.parent  = ()->
    if this.parent is undefined
      this.parent = if this.parentId then new CanvasElement( Design.instance().component( this.parentId ) ) else null

    this.parent

  CanvasElement.prototype.append = ( child )->
    if this.type isnt "group"
      return false

    if _.isString( child )
      childComp = Design.instance().component( if _.isString( child ) then child else child.id )
      if not childComp
        return false

    parentComp = Design.instance().component( this.id )
    res = childComp.isReparentable( parentComp )

    if _.isString( res )
      # Error
      notification "error", res

    else if res is true
      # Do remove
      parentComp.addChild( child )
      return true

    return false

  CanvasElement.prototype.children = ()->
    _.map Design.instance().component( this.id ).children() || [], ( c )->
        new CanvasElement( c )

  CanvasElement.line = ( component )->
    this.id = component.id

  CanvasElement.line.prototype.select   = CanvasElement.prototype.select
  CanvasElement.line.prototype.element  = CanvasElement.prototype.element
  CanvasElement.line.prototype.$element = CanvasElement.prototype.$element

  CanvasElement
