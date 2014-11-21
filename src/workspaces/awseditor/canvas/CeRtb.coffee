
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeRtb"
    ### env:dev:end ###
    type : constant.RESTYPE.RT

    parentType  : [ constant.RESTYPE.VPC ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "rtb-tgt-left"   : [ 10, 35, CanvasElement.constant.PORT_LEFT_ANGLE, 8, 35]
      "rtb-tgt-right"  : [ 70, 35, CanvasElement.constant.PORT_RIGHT_ANGLE, 72, 35 ]
      "rtb-src-top"    : [ 40, 3,  CanvasElement.constant.PORT_UP_ANGLE ]
      "rtb-src-bottom" : [ 40, 77, CanvasElement.constant.PORT_DOWN_ANGLE ]
    }
    portDirMap : {
      "rtb-tgt" : "horizontal"
      "rtb-src" : "vertical"
    }

    iconUrl : ()->
      if @model.get("main") then "ide/icon/cvs-rtb-main.png" else "ide/icon/cvs-rtb.png"

    listenModelEvents : ()->
      @listenTo @model, "change:main", @render
      return

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
          'data-tooltip' : lang.IDE.PORT_TIP_B
        })
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'rtb-tgt'
          'data-alias'   : 'rtb-tgt-right'
          'data-tooltip' : lang.IDE.PORT_TIP_B
        })
        svg.use("port_bottom").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'rtb-src'
          'data-alias'   : 'rtb-src-top'
          'data-tooltip' : lang.IDE.PORT_TIP_A
        })
        svg.use("port_top").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'rtb-src'
          'data-alias'   : 'rtb-src-bottom'
          'data-tooltip' : lang.IDE.PORT_TIP_A
        })
      ])

      @canvas.appendNode node
      @initNode node, m.x(), m.y()
      node

    labelWidth : (width)-> CanvasElement.prototype.labelWidth.call(this, width) - 20
    # Update the svg element
    render : ()->
      CanvasManager.setLabel @, @$el.children(".node-label")
      CanvasManager.update @$el.children("image"), @iconUrl(), "href"

  }
