
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js", "./CanvasView" ], ( CanvasElement, constant, CanvasManager, lang, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeSubnetGroup"
    ### env:dev:end ###
    type : constant.RESTYPE.DBSBG

    parentType  : [ constant.RESTYPE.VPC ]
    defaultSize : [ 19, 19 ]

    listenModelEvents : ()->
      return

    # Creates a svg element
    create : ()->
      svg = @canvas.svg

      svgEl = @canvas.appendSubnet( @createGroup() )
      svgEl.add([
        svg.image(MC.IMG_URL + 'ide/icon/sbg-info.png', 12, 12).move(4,4).classes('tooltip')
      ])

      $( svgEl.node ).children(".group-label").attr({
        "x": 18
        "y": 14
      })

      m = @model
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      @$el.children("text").text m.get('name')
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH
  }
