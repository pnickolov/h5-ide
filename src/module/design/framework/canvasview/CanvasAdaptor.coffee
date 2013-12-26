define [ "./CanvasElement" ], ( CanvasElement )->

  Design = null

  ### $canvas is a adaptor for MC.canvas.js ###
  $canvas = ( id )->
    component = Design.__instance.component(id)
    if component.node_line
      new CanvasElement.line( component )
    else
      new CanvasElement( component )

  $canvas.size   = ( w, h  )-> Design.__instance.canvas.size( w, h )
  $canvas.scale  = ( ratio )-> Design.__instance.canvas.scale( ratio )
  $canvas.offset = ( x, y  )-> Design.__instance.canvas.offset( x, y )
  $canvas.node   = ()->
    _.map Design.__instance.__canvasNodes, ( comp )->
      new CanvasElement( comp )

  $canvas.group  = ()->
    _.map Design.__instance.__canvasGroups, ( comp )->
      new CanvasElement( comp )

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

