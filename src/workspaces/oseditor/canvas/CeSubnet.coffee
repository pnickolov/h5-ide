
define [ "CanvasElement", "constant", "CanvasManager", "CanvasView", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, CanvasView, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsSubnet"
    ### env:dev:end ###
    type : constant.RESTYPE.OSSUBNET

    parentType  : [ constant.RESTYPE.OSNETWORK ]
    defaultSize : [ 13, 13 ]

    portPosition : ( portName, isAtomic )->
      portY = @model.height() * CanvasView.GRID_HEIGHT / 2 - 5
      [ -12, portY, CanvasElement.constant.PORT_LEFT_ANGLE ]

    # Creates a svg element
    create : ()->
      svg = @canvas.svg

      svgEl = @canvas.appendSubnet( @createGroup() )
      svgEl.add([
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'route'
          'data-tooltip' : lang.IDE.PORT_TIP_L
        })
      ])
      m = @model
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.update( @$el.children("text"), m.get("name") )
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

  }
