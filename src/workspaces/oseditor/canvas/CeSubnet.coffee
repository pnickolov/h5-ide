
define [ "CanvasElement", "constant", "CanvasManager", "CanvasView", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, CanvasView, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsSubnet"
    ### env:dev:end ###
    type : constant.RESTYPE.OSSUBNET

    parentType  : [ constant.RESTYPE.OSNETWORK ]
    defaultSize : [ 13, 13 ]

    portDirMap : {
      "route" : "vertical"
    }

    listenModelEvents : ()->
      @listenTo @model, "change:public", @render
      @listenTo @model, "change:cidr", @render
      return

    portPosition : ( portName, isAtomic )->
      m = @model
      portX = m.width() * CanvasView.GRID_WIDTH / 2

      if portName is "route-top"
        [ portX, -5, CanvasElement.constant.PORT_UP_ANGLE ]
      else
        [ portX, m.height() * CanvasView.GRID_HEIGHT + 5, CanvasElement.constant.PORT_DOWN_ANGLE ]

    # Creates a svg element
    create : ()->
      svg = @canvas.svg

      svgEl = @canvas.appendSubnet( @createGroup() )
      svgEl.add([
        @createPortElement().attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'route'
          'data-alias'   : 'route-top'
          'data-tooltip' : lang.IDE.PORT_TIP_L
        })

        @createPortElement().attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'route'
          'data-alias'   : 'route-bottom'
          'data-tooltip' : lang.IDE.PORT_TIP_L
        })

        svg.image( MC.IMG_URL + "ide/icon-os/cvs-subnet.png", 12, 12 ).move(5, 5).classes("public tooltip").attr('data-tooltip':"Public subnet")
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
