
define [ "./CanvasElement", "constant", "./CanvasManager", "./CanvasView" ], ( CanvasElement, constant, CanvasManager, CanvasView )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeVpc"
    ### env:dev:end ###
    type : constant.RESTYPE.VPC

    parentType  : [ "SVG" ]

    listenModelEvents : ()->
      @listenTo @model, "change:cidr", @render
      return

    # Creates a svg element
    create : ()-> @canvas.appendVpc( @createGroup() )

    siblings : ()->
      canvas = @canvas
      canvas.design.componentsOfType( constant.RESTYPE.CGW ).map ( m )-> canvas.getItem( m.id )

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      @$el.children("text").text "#{m.get('name')} (#{m.get('cidr')})"
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

  }
