
define [ "./CanvasElement", "constant", "CanvasManager", "./CanvasView" ], ( CanvasElement, constant, CanvasManager, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeAz"
    ### env:dev:end ###
    type : constant.RESTYPE.AZ

    parentType  : [ constant.RESTYPE.VPC ]
    defaultSize : [ 23, 23 ]

    # Creates a svg element
    create : ()-> @canvas.appendAz( @createGroup() )

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.update( @$el.children("text"), m.get("name") )
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

  }, {
    createResource : ( type, attr, option )->
      attr.x += 1
      attr.y += 1
      attr.width  = 21
      attr.height = 21
      azModel = CanvasElement.createResource( type, attr, option )

      # Create a subnet
      attr.x += 2
      attr.y += 2
      attr.width  -= 4
      attr.height -= 4
      attr.parent = azModel

      CanvasElement.createResource( constant.RESTYPE.SUBNET, attr, option )
  }
