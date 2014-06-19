
define [ "./CanvasElement", "constant", "CanvasManager","i18n!nls/lang.js"], ( CanvasElement, constant, CanvasManager, lang )->

  CeRtb = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeRtb, constant.RESTYPE.RT )
  ChildElementProto = CeRtb.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "rtb-tgt-left"   : [ 10, 35, CanvasElement.constant.PORT_LEFT_ANGLE ]
    "rtb-tgt-right"  : [ 70, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    "rtb-src-top"    : [ 40, 3,  CanvasElement.constant.PORT_UP_ANGLE ]
    "rtb-src-bottom" : [ 40, 77, CanvasElement.constant.PORT_DOWN_ANGLE ]
  }
  ChildElementProto.portDirMap = {
    "rtb-tgt" : "horizontal"
    "rtb-src" : "vertical"
  }


  ChildElementProto.iconUrl = ()->
      if @model.get("main") then "ide/icon/rt-main-canvas.png" else "ide/icon/rt-canvas.png"

  ChildElementProto.draw = ( isCreate )->

    m = @model

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : @iconUrl()
        imageX  : 10
        imageY  : 13
        imageW  : 60
        imageH  : 57
      })

      node.append(
        # Left port
        Canvon.path(this.constant.PATH_PORT_LEFT).attr({
          'class'          : 'port port-blue port-rtb-tgt port-rtb-tgt-left tooltip'
          'data-name'      : 'rtb-tgt'
          'data-alias'     : 'rtb-tgt-left'
          'data-position'  : 'left'
          'data-type'      : 'sg'
          'data-direction' : 'out'
          'data-tooltip'   : lang.ide.PORT_TIP_B
        }),

        # Right port
        Canvon.path(this.constant.PATH_PORT_RIGHT).attr({
          'class'          : 'port port-blue  port-rtb-tgt port-rtb-tgt-right tooltip'
          'data-name'      : 'rtb-tgt'
          'data-alias'     : 'rtb-tgt-right'
          'data-position'  : 'right'
          'data-type'      : 'sg'
          'data-direction' : 'out'
          'data-tooltip'   : lang.ide.PORT_TIP_B
        }),

        # Top port
        Canvon.path(this.constant.PATH_PORT_BOTTOM).attr({
          'class'          : 'port port-gray port-rtb-src port-rtb-src-top tooltip'
          'data-name'      : 'rtb-src'
          'data-alias'     : 'rtb-src-top'
          'data-position'  : 'top'
          'data-type'      : 'association'
          'data-direction' : 'in'
          'data-tooltip'   : lang.ide.PORT_TIP_A
        }),

        # Bottom port
        Canvon.path(this.constant.PATH_PORT_TOP).attr({
          'class'          : 'port port-gray port-rtb-src port-rtb-src-bottom tooltip'
          'data-name'      : 'rtb-src'
          'data-alias'     : 'rtb-src-bottom'
          'data-position'  : 'bottom'
          'data-type'      : 'association'
          'data-direction' : 'in'
          'data-tooltip'   : lang.ide.PORT_TIP_A
        }),

        Canvon.text(41, 27, m.get("name")).attr({'class':'node-label node-label-rtb-name'})
      )

      # Move the node to right place
      @getLayer("node_layer").append node
      @initNode node, m.x(), m.y()

    else
      node = @$element()
      # Update label
      CanvasManager.update node.children(".node-label"), m.get("name")

      # Update Image
      CanvasManager.update node.children("image"), @iconUrl(), "href"

    # Update Resource State in app view
    @updateAppState()
    null

  null
