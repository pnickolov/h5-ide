
define [ "./CanvasElement", "constant", "CanvasManager","i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager,lang )->

  CeDBSbg = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeDBSbg, constant.RESTYPE.DBSBG )
  ChildElementProto = CeDBSbg.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosition = ( portName )->
    m = @model
    portY = m.height() * MC.canvas.GRID_HEIGHT / 2 - 5

    if portName is "subnet-assoc-in"
      [ -12, portY, CanvasElement.constant.PORT_LEFT_ANGLE ]
    else
      [ m.width() * MC.canvas.GRID_WIDTH + 10, portY, CanvasElement.constant.PORT_RIGHT_ANGLE ]


  ChildElementProto.draw = ( isCreate )->

    m = @model

    label = "#{m.get('name')}"

    if isCreate
      node = @createGroup( label )

      @getLayer("subnet_layer").append node

      # Move the group to right place
      @initNode node, m.x(), m.y()

    else
      CanvasManager.update( @$element().children("text"), label )

    null

  #override CanvasElement.prototype.select() in CanvasElement
  ChildElementProto.select = ()->
    m = @model
    @doSelect( m.type, m.id, m.id )
    @showRelatedSubnet()
    true

  #highlight related subnet
  ChildElementProto.showRelatedSubnet = ()->
    m = @model
    Design.modelClassForType(constant.RESTYPE.SUBNET).each (sb) ->
      if sb.get('name') in m.get('subnetIds')
        Canvon('#' + sb.id).addClass('selected')
      else
        Canvon('#' + sb.id).removeClass('selected')

  null
