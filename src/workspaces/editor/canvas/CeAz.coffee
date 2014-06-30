
define [ "./CanvasElement", "constant", "CanvasManager" ], ( CanvasElement, constant, CanvasManager )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeAz"
    ### env:dev:end ###
    type : constant.RESTYPE.AZ

    # Creates a svg element
    create : ()-> @canvas.appendAz( @createGroup() )

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.update( @$el.children("text"), m.get("name") )
      @$el[0].instance.move m.x() * MC.canvas.GRID_WIDTH, m.y() * MC.canvas.GRID_WIDTH

  }
