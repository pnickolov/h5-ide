
define [ "./CanvasElement", "CanvasManager" ], ( CanvasElement, CanvasManager )->

  ChildElement = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( ChildElement, "Line" )
  ChildElementProto = ChildElement.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portName = ( targetId )-> @model.port( targetId, "name" )

  ChildElementProto.reConnect = ()-> @draw()

  ChildElementProto.draw = ()-> CanvasManager.drawLine( @model )

  null
