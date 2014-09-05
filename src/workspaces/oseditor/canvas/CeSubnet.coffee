
define [ "CanvasElement", "constant", "CanvasManager", "CanvasView" ], ( CanvasElement, constant, CanvasManager, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsSubnet"
    ### env:dev:end ###
    type : constant.RESTYPE.OSSUBNET

    parentType  : [ constant.RESTYPE.OSNETWORK ]
    defaultSize : [ 13, 13 ]

    # Creates a svg element
    create : ()-> @canvas.appendSubnet( @createGroup() )

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.update( @$el.children("text"), m.get("name") )
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

  }
