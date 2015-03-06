
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js", "CanvasView" ], ( CanvasElement, constant, CanvasManager, lang, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeMarathonGroup"
    ### env:dev:end ###
    type : constant.RESTYPE.MRTHGROUP

    parentType  : [ constant.RESTYPE.MRTHGROUP, "SVG" ]
    defaultSize : [ 19, 19 ]

    portPosition : ( portName, isAtomic )->
      m = @model

      if portName is "group-dep-in"
        [ -12, 10, CanvasElement.constant.PORT_LEFT_ANGLE ]
      else
        x = m.width() * CanvasView.GRID_WIDTH + 4
        if isAtomic then x += 8
        [ x, 10, CanvasElement.constant.PORT_RIGHT_ANGLE ]

    listenModelEvents : ()->
      # @listenTo @model, "change:cidr", @render
      return

    applyGeometry : ( x, y, width, height )->
      CanvasElement.prototype.applyGeometry.apply this, arguments

      for ch in @$el[0].instance.children()
        classes = ch.classes()
        if classes.indexOf("group-label-bg") >= 0
          ch.size( width * 10, ch.height() )
          break

      return

    # Creates a svg element
    create : ()->
      svg = @canvas.svg

      m = @model
      svgEl = @canvas.appendGroup( @createGroup() )
      svgEl.add([
        svg.rect( m.width() * 10, 20 ).move(0,0).radius(2).attr({
          'class' : "group-label-bg"
        })
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'group-dep-in'
          'data-tooltip' : lang.IDE.PORT_TIP_L
        })
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'group-dep-out'
          'data-tooltip' : lang.IDE.PORT_TIP_M
        })
      ], 0)
      @initNode svgEl, m.x(), m.y()
      svgEl

    label : ()-> @model.get('name')

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.setLabel @, @$el.children("text")
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

    # Override to make the connect-line functionality more tolerant
    containPoint : ( px, py )->
      x = @model.x() - 2
      y = @model.y()
      size = @size()

      x <= px and y <= py and x + size.width + 4 >= px and y + size.height >= py

    parentCount : ()->
      c = 0
      a = @parent()
      while a
        ++c
        a = a.parent()
      c
  }
