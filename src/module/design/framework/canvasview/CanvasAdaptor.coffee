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

  $canvas.size = ( w, h )->
    if Design.__instance
      return Design.__instance.canvas.size( w, h )
    else
      return [240, 240]

  $canvas.scale         = ( ratio )-> Design.__instance.canvas.scale( ratio )
  $canvas.offset        = ()-> $(document.getElementById("svg_canvas")).offset()
  $canvas.selected_node = ()-> Design.__instance.canvas.selectedNode
  $canvas.lineStyle     = (ls)->
    if ls is undefined
      if Design.__instance
        return Design.__instance.canvas.lineStyle
      else
        return 0

    Design.__instance.canvas.lineStyle = ls

    if Design.__instance.shouldDraw()
      # Update SgLine
      _.each Design.modelClassForType("SgRuleLine").allObjects(), ( cn )->
        cn.draw()
    null

  $canvas.node      = ()->
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
    attributes.x = coordinate.x
    attributes.y = coordinate.y
    if attributes.groupUId
      attributes.parent = Design.instance().__componentMap[ attributes.groupUId ]
    model = new Model( attributes )
    return { id : model.id }

  $canvas.connect = ( p1, p1Name, p2, p2Name )->
    Design.instance().createConnection( p1, p1Name, p2, p2Name )
    null

  $canvas.connection = ( uid )->
    if uid
      cache = { uid : Design.__instance.component( uid ) }
    else
      cache = Design.__instance.__canvasLines

    lineArray = {}
    for uid, line of cache
      l = {
        type   : line.get("lineType")
        target : {}
      }
      l.target[ line.port1Comp().id ] = line.port1("name")
      l.target[ line.port2Comp().id ] = line.port2("name")

      lineArray[ uid ] = l


    if uid
      return lineArray.uid
    else
      return lineArray


  # CanvasEvent is used to deal with the event that will trigger by MC.canvas.js
  CanvasEvent = {
    CANVAS_NODE_SELECTED : ()->
      ide_event.trigger ide_event.OPEN_PROPERTY
      null

    SHOW_PROPERTY_PANEL : ()->
      ide_event.trigger ide_event.OPEN_PROPERTY
      null
  }

  window.$canvas = $canvas



  ### Canvas is used by $canvas to store data of svg canvas ###
  Canvas = ( size )->
    this.sizeAry      = size || [240, 240]
    this.offsetAry    = [0, 0]
    this.scaleAry     = 1
    this.lineStyle    = 2  # 0:straight  1:elbow line(fold)  2:bezier q,  3:bezier qt
    this.selectedNode = []
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

