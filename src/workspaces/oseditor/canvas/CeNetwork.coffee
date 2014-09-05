
define [ "CanvasElement", "constant", "CanvasManager", "CanvasView" ], ( CanvasElement, constant, CanvasManager, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsNetwork"
    ### env:dev:end ###
    type : constant.RESTYPE.OSNETWORK

    parentType  : [ "SVG" ]
    defaultSize : [ 60, 60 ]

    # Creates a svg element
    create : ()-> @canvas.appendNetwork( @createGroup() )

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.update( @$el.children("text"), m.get("name") )
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

  }
