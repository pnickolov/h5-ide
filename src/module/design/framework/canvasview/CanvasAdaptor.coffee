define [ "./CanvasElement", "event" ], ( CanvasElement, ide_event )->

  Design = null

  ### $canvas is a adaptor for MC.canvas.js ###
  $canvas = ( id )->
    component = Design.__instance.component(id)
    if not component
      component = { id : id }
      quick = true

    if component.node_line
      new CanvasElement.line( component )
    else
      new CanvasElement( component, quick )

  $canvas.size   = ( w, h  )-> Design.__instance.canvas.size( w, h )
  $canvas.scale  = ( ratio )-> Design.__instance.canvas.scale( ratio )
  $canvas.offset = ()-> $("#svg_canvas").offset()
  $canvas.node   = ()->
    _.map Design.__instance.__canvasNodes, ( comp )->
      new CanvasElement( comp )

  $canvas.group  = ()->
    _.map Design.__instance.__canvasGroups, ( comp )->
      new CanvasElement( comp )

  $canvas.trigger = ( event )->
    console.assert( _.isString( event ), "Invalid parameter : event " )

    if CanvasEvent[event]
      CanvasEvent[event].apply( this, Array.prototype.slice.call(arguments) )
    null

  $canvas.add = ( type, attributes, coordinate )->
    Model = Design.modelClassForType type
    new Model( attributes )
    null

  # CanvasEvent is used to deal with the event that will trigger by MC.canvas.js
  CanvasEvent = {
    CANVAS_NODE_SELECTED : ()->
      ide_event.trigger ide_event.SHOW_PROPERTY_PANEL
      null

    SHOW_PROPERTY_PANEL : ()->
      ide_event.trigger ide_event.SHOW_PROPERTY_PANEL
      null
  }

  window.$canvas = $canvas



  ### Canvas is used by $canvas to store data of svg canvas ###
  Canvas = ( size )->
    this.sizeAry   = size
    this.offsetAry = [0, 0]
    this.scaleAry  = 1
    this

  Canvas.prototype.scale = ( ratio )->
    if ratio is undefined
      return this.scaleAry

    this.scaleAry = ratio
    null

  Canvas.prototype.offset = ( x, y )->
    if x is undefined
      return this.offsetAry

    this.offsetAry[0] = x
    this.offsetAry[1] = y
    null

  Canvas.prototype.size = ( w, h )->
    if w is undefined
      return this.sizeAry

    this.sizeAry[0] = w
    this.sizeAry[1] = h
    null

  Canvas.setDesign = ( design )->
    Design = design
    CanvasElement.setDesign( design )
    null

  Canvas

