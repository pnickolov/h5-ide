
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
      Canvon('#' + m.id).addClass('tooltip')

    else
      CanvasManager.update( @$element().children("text"), label )

    @updateTooltip()

    null

  #override CanvasElement.prototype.select() in CanvasElement
  ChildElementProto.select = ()->
    m = @model
    @doSelect( m.type, m.id, m.id )
    @showRelatedSubnet( true )
    true

  #highlight related subnet
  ChildElementProto.showRelatedSubnet = ( noNeedUpdateTooltip )->
    m = @model
    relatedSb = _.map m.connectionTargets("SbAsso"), ( sb )-> sb.id
    if not noNeedUpdateTooltip
      @updateTooltip()

    Design.modelClassForType(constant.RESTYPE.SUBNET).each (sb) ->
      if sb.id in relatedSb
        Canvon('#' + sb.id).addClass('selected')
      else
        Canvon('#' + sb.id).removeClass('selected')

  #update tooltip
  ChildElementProto.updateTooltip = ()->
    m = @model
    if !relatedSb
      relatedSb = _.map m.connectionTargets("SbAsso"), ( sb )-> sb.get('name')
    if relatedSb and relatedSb.length > 0
      tooltip = relatedSb.join(', ')
    else
      tooltip = "No subnet is assigned to this subnet group yet"
    Canvon('#' + m.id)
      .attr('data-tooltip', tooltip)
      .data('tooltip', tooltip)

  null
