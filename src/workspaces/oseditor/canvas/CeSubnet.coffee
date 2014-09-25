
define [ "CanvasElement", "constant", "CanvasManager", "CanvasView", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, CanvasView, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsSubnet"
    ### env:dev:end ###
    type : constant.RESTYPE.OSSUBNET

    parentType  : [ constant.RESTYPE.OSNETWORK ]
    defaultSize : [ 13, 13 ]

    portDirMap : {
      "route" : "horizontal"
    }

    listenModelEvents : ()->
      @listenTo @model, "change:public", @render
      @listenTo @model, "change:cidr", @render
      return

    portPosition : ( portName, isAtomic )->
      m = @model
      portY = m.height() * CanvasView.GRID_HEIGHT / 2 - 5

      if portName is "route-left"
        [ -12, portY, CanvasElement.constant.PORT_LEFT_ANGLE ]
      else
        x = m.width() * CanvasView.GRID_WIDTH + 4
        if isAtomic then x += 8
        [ x, portY, CanvasElement.constant.PORT_RIGHT_ANGLE ]

    # Creates a svg element
    create : ()->
      svg = @canvas.svg

      svgEl = @canvas.appendSubnet( @createGroup() )
      svgEl.add([
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'route'
          'data-alias'   : 'route-left'
          'data-tooltip' : lang.IDE.PORT_TIP_L
        })
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'route'
          'data-alias'   : 'route-right'
          'data-tooltip' : lang.IDE.PORT_TIP_M
        })
        svg.circle(8).move(5, 6).classes('public').attr("fill","#009EFF")
      ])
      m = @model
      @initNode svgEl, m.x(), m.y()
      svgEl

    label : ()-> "#{@model.get('name')} (#{@model.get('cidr')})"
    labelWidth : ( width )->
      w = CanvasElement.prototype.labelWidth.call(this, width)
      if @model.get("public")
        w -= 16
      w

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.setLabel @, @$el.children("text")
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

      # Move Label
      @$el.children("text")[0].setAttribute("x", if m.get("public") then 21 else 5 )
      CanvasManager.toggle( @$el.children(".public"), m.get("public") )

  }
