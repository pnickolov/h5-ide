
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeRtb"
    ### env:dev:end ###
    type : constant.RESTYPE.RT

    parentType  : [ constant.RESTYPE.VPC ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "rtb-tgt-left"   : [ 10, 35, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "rtb-tgt-right"  : [ 70, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "rtb-src-top"    : [ 40, 3,  CanvasElement.constant.PORT_UP_ANGLE ]
      "rtb-src-bottom" : [ 40, 77, CanvasElement.constant.PORT_DOWN_ANGLE ]
    }
    portDirMap : {
      "rtb-tgt" : "horizontal"
      "rtb-src" : "vertical"
    }

    iconUrl : ()->
      if @model.get("main") then "ide/icon/rt-main-canvas.png" else "ide/icon/rt-canvas.png"

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : @iconUrl()
        imageX  : 10
        imageY  : 13
        imageW  : 60
        imageH  : 57
      }).add([
        svg.text("").move(41, 27).classes('node-label')

        svg.use("port_left").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'rtb-tgt'
          'data-alias'   : 'rtb-tgt-left'
          'data-tooltip' : lang.ide.PORT_TIP_B
        })
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'rtb-tgt'
          'data-alias'   : 'rtb-tgt-right'
          'data-tooltip' : lang.ide.PORT_TIP_B
        })
        svg.use("port_bottom").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'rtb-src'
          'data-alias'   : 'rtb-src-top'
          'data-tooltip' : lang.ide.PORT_TIP_A
        })
        svg.use("port_top").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'rtb-src'
          'data-alias'   : 'rtb-src-bottom'
          'data-tooltip' : lang.ide.PORT_TIP_A
        })
      ])

      @canvas.appendNode node
      @initNode node, m.x(), m.y()
      node

    # Update the svg element
    render : ()->
      CanvasManager.update @$el.children(".node-label"), @model.get("name")
      CanvasManager.update @$el.children("image"), @iconUrl(), "href"

  }
