
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js", "CanvasView" ], ( CanvasElement, constant, CanvasManager, lang, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeSubnet"
    ### env:dev:end ###
    type : constant.RESTYPE.SUBNET

    parentType  : [ constant.RESTYPE.AZ ]
    defaultSize : [ 19, 19 ]

    portPosition : ( portName, isAtomic )->
      m = @model
      portY = m.height() * CanvasView.GRID_HEIGHT / 2 - 5

      if portName is "subnet-assoc-in"
        [ -12, portY, CanvasElement.constant.PORT_LEFT_ANGLE ]
      else
        x = m.width() * CanvasView.GRID_WIDTH + 4
        if isAtomic then x += 8
        [ x, portY, CanvasElement.constant.PORT_RIGHT_ANGLE ]


    listenModelEvents : ()->
      @listenTo @model, "change:cidr", @render
      return

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

    label : ()-> "#{@model.get('name')} (#{@model.get('cidr')})"

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
  }
