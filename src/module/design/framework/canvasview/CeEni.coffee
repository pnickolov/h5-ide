
define [ "./CanvasElement", "constant", "CanvasManager","i18n!nls/lang.js" ], ( CanvasElement, constant, CanvasManager,lang )->

  CeEni = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeEni, constant.RESTYPE.ENI )
  ChildElementProto = CeEni.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "eni-sg-left"  : [ 10, 20, MC.canvas.PORT_LEFT_ANGLE  ]
    "eni-attach"   : [ 8,  50, MC.canvas.PORT_LEFT_ANGLE  ]
    "eni-sg-right" : [ 80, 20, MC.canvas.PORT_RIGHT_ANGLE ]
    "eni-rtb"      : [ 45, 0,  MC.canvas.PORT_UP_ANGLE    ]
  }

  ChildElementProto.portDirMap = {
    "eni-sg" : "horizontal"
  }

  ChildElementProto.iconUrl = ()->
    if @model.connections( "EniAttachment" ).length
      "ide/icon/eni-canvas-attached.png"
    else
      "ide/icon/eni-canvas-unattached.png"

  ChildElementProto.draw = ( isCreate )->

    m = @model

    if m.embedInstance()
      # Do nothing if this is embed eni, a.k.a the internal eni of an Instance
      return

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : @iconUrl()
        imageX  : 16
        imageY  : 15
        imageW  : 59
        imageH  : 49
        label   : m.get("name")
        labelBg : true
        sg      : true
      })

      node.append(
        Canvon.image( "", 44,37,12,14 ).attr({
          'id'    : "#{@id}_eip_status"
          'class' : 'eip-status tooltip'
        }),

        # Left Port
        Canvon.path(MC.canvas.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-eni-sg port-eni-sg-left tooltip'
          'data-name'      : 'eni-sg'
          'data-alias'     : 'eni-sg-left'
          'data-position'  : 'left'
          'data-type'      : 'sg'
          'data-direction' : "in"
          'data-tooltip'   : lang.ide.PORT_TIP_D
        }),

        # Left port
        Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
          'class'          : 'port port-green port-eni-attach tooltip'
          'data-name'      : 'eni-attach'
          'data-position'  : 'left'
          'data-type'      : 'attachment'
          'data-direction' : "in"
          'data-tooltip'   : lang.ide.PORT_TIP_G
        }),

        # Right port
        Canvon.path(MC.canvas.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-eni-sg port-eni-sg-right tooltip'
          'data-name'      : 'eni-sg'
          'data-alias'     : 'eni-sg-right'
          'data-position'  : 'right'
          'data-type'      : 'sg'
          'data-direction' : 'out'
          'data-tooltip'   : lang.ide.PORT_TIP_F
        }),

        # Top port(blue)
        Canvon.path(MC.canvas.PATH_PORT_BOTTOM).attr({
          'class'      : 'port port-blue port-eni-rtb tooltip'
          'data-name'     : 'eni-rtb'
          'data-position' : 'top'
          'data-type'     : 'sg'
          'data-direction': 'in'
          'data-tooltip'  : lang.ide.PORT_TIP_C
        }),

        Canvon.group().append(
          Canvon.rectangle(36, 1, 20, 16).attr({'class':'server-number-bg','rx':4,'ry':4}),
          Canvon.text(46, 13, "0").attr({'class':'node-label server-number'})
        ).attr({
          'class'   : 'eni-number-group'
          'display' : "none"
        })

      )

      # Move the node to right place
      @getLayer("node_layer").append node
      @initNode node, m.x(), m.y()

    else
      node = @$element()
      # Update label
      CanvasManager.update node.children(".node-label"), m.get("name")

      # Update Image
      CanvasManager.update node.children("image:not(.eip-status)"), @iconUrl(), "href"

    # Update SeverGroup Count
    count = m.serverGroupCount()

    numberGroup = node.children(".eni-number-group")
    if count > 1
      CanvasManager.toggle node.children(".port-eni-rtb"), false
      CanvasManager.toggle numberGroup, true
      CanvasManager.update numberGroup.children("text"), count
    else
      CanvasManager.toggle node.children(".port-eni-rtb"), true
      CanvasManager.toggle numberGroup, false

    # Update EIP
    CanvasManager.toggle node.children(".eip-status"), !!m.attachedInstance()
    CanvasManager.updateEip node.children(".eip-status"), m

    @updateAppState()

    null

  ChildElementProto.select = ( subId )->
    m      = @model
    type   = m.type
    design = m.design()

    if not subId

      if design.modeIsApp()
        if m.serverGroupCount() > 1
          type = "component_eni_group"

      else if design.modeIsAppEdit() and m.get("appId")
        type = "component_eni_group"

    @doSelect( type, subId or @model.id, @model.id )
    true

  null
