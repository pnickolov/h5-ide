
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js", "./CanvasView" ], ( CanvasElement, constant, CanvasManager, lang, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeSubnet"
    ### env:dev:end ###
    type : constant.RESTYPE.SUBNET

    parentType  : [ constant.RESTYPE.AZ ]
    defaultSize : [ 19, 19 ]

    portPosition : ( portName )->
      m = @model
      portY = m.height() * CanvasView.GRID_HEIGHT / 2 - 5

      if portName is "subnet-assoc-in"
        [ -12, portY, CanvasElement.constant.PORT_LEFT_ANGLE ]
      else
        [ m.width() * CanvasView.GRID_WIDTH + 4, portY, CanvasElement.constant.PORT_RIGHT_ANGLE ]

    # Creates a svg element
    create : ()->
      svg = @canvas.svg

      svgEl = @canvas.appendSubnet( @createGroup() )
      svgEl.add([
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'subnet-assoc-in'
          'data-tooltip' : lang.ide.PORT_TIP_L
        })
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'subnet-assoc-out'
          'data-tooltip' : lang.ide.PORT_TIP_M
        })
      ])
      m = @model
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      svgEl = @$el[0].instance
      @initNode svgEl, m.x(), m.y()
      @$el.children("text").text "#{m.get('name')} (#{m.get('cidr')})"
      svgEl.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

  }
