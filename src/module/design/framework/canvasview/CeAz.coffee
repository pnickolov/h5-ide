
define [ "./CanvasElement", "constant", "CanvasManager" ], ( CanvasElement, constant, CanvasManager )->

  ChildElement = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( ChildElement, constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone )
  ChildElementProto = ChildElement.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.select = ()->
    if not @model.design().modeIsStack()
      @doSelect( "", "", @model.id )
    else
      @doSelect( @model.type, @model.id, @model.id )

  ChildElementProto.draw = ( isCreate ) ->

    m = @model

    name = m.get("name")

    if isCreate
      node = @createGroup( name )
      @getLayer("az_layer").append node

      # Move the group to right place
      CanvasManager.position node, m.x(), m.y()

    else
      CanvasManager.update( @$element().children("text"), name )
    null

  null
