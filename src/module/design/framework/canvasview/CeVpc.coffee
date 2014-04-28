
define [ "./CanvasElement", "constant", "CanvasManager" ], ( CanvasElement, constant, CanvasManager )->

  CeVpc = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeVpc, constant.RESTYPE.VPC )
  ChildElementProto = CeVpc.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.draw = ( isCreate )->
    m = @model
    label = "#{m.get('name')} (#{m.get('cidr')})"

    if isCreate
      node = @createGroup( label )
      @getLayer("vpc_layer").append node

      # Move the group to right place
      CanvasManager.position node, m.x(), m.y()

    else
      CanvasManager.update( @$element().children("text"), label )

    null

  null
