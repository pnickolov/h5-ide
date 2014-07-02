
define [ "i18n!/nls/lang.js", "./CanvasElement", "constant", "CanvasManager", "Design", "CloudResources" ], ( lang, CanvasElement, constant, CanvasManager, Design, CloudResources )->

  CeDBInstance = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeDBInstance, constant.RESTYPE.DBINSTANCE )
  ChildElementProto = CeDBInstance.prototype

  ChildElementProto.iconUrl = ->
    'ide/icon/ebs-snapshot-resource-1109.png'

  ChildElementProto.draw = ( isCreate ) ->
    m = @model

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : "ide/icon/instance-canvas.png"
        imageX  : 15
        imageY  : 9
        imageW  : 61
        imageH  : 62
        label   : m.get("name")
        labelBg : true
        sg      : true
      })

      # Insert Volume / Eip / Port
      node.append(
        # Ami Icon
        Canvon.image( MC.IMG_URL + @iconUrl(), 30, 15, 39, 27 ).attr({'class':"ami-image"}),


        # left port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-instance-sg port-instance-sg-left tooltip'
          'data-name'      : 'instance-sg' #for identify port
          'data-alias'     : 'instance-sg-left'
          'data-position'  : 'left' #port position: for calc point of junction
          'data-type'      : 'sg'   #color of line
          'data-direction' : 'in'   #direction
          'data-tooltip'   : lang.ide.PORT_TIP_D
        }),

        # right port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-instance-sg port-instance-sg-right tooltip'
          'data-name'      : 'instance-sg'
          'data-alias'     : 'instance-sg-right'
          'data-position'  : 'right'
          'data-type'      : 'sg'
          'data-direction' : 'out'
          'data-tooltip'   : lang.ide.PORT_TIP_D
        })

        # RTB/ENI Port
        Canvon.path(this.constant.PATH_PORT_RIGHT).attr({
            'class'      : 'port port-green port-instance-attach tooltip'
            'data-name'     : 'instance-attach'
            'data-position' : 'right'
            'data-type'     : 'attachment'
            'data-direction': 'out'
            'data-tooltip'  : lang.ide.PORT_TIP_E
        })

        Canvon.path(this.constant.PATH_PORT_BOTTOM).attr({
            'class'      : 'port port-blue port-instance-rtb tooltip'
            'data-name'     : 'instance-rtb'
            'data-position' : 'top'
            'data-type'     : 'sg'
            'data-direction': 'in'
            'data-tooltip'  : lang.ide.PORT_TIP_C
        })
      )

      if not @model.design().modeIsStack() and m.get("appId")
        # instance-state
        node.append(
          Canvon.circle(68, 15, 5,{}).attr({
            'id'    : "#{@id}_instance-state"
            'class' : 'instance-state instance-state-unknown'
          })
        )

      # Move the node to right place
      @getLayer("node_layer").append node
      @initNode node, m.x(), m.y()

    else
      node = @$element()
      # update label
      CanvasManager.update node.children(".node-label-name"), m.get("name")

    if not @model.design().modeIsStack() and m.get("appId")
      # Update Instance State in app
      @updateAppState()

    # Update Ami Image
    CanvasManager.update node.children(".ami-image"), @iconUrl(), "href"




    null




  CeDBInstance
