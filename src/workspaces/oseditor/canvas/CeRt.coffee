
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsRt"
    ### env:dev:end ###
    type : constant.RESTYPE.OSRT

    parentType  : [ "SVG" ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "external" : [ 10, 35, CanvasElement.constant.PORT_LEFT_ANGLE,  8, 35]
      "route"    : [ 70, 35, CanvasElement.constant.PORT_RIGHT_ANGLE, 72, 35 ]
    }

    iconUrl : ()-> "ide/icon/cvs-rtb.png"

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
          'data-name'    : 'external'
          'data-tooltip' : lang.IDE.PORT_TIP_B
        })
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'route'
          'data-tooltip' : lang.IDE.PORT_TIP_B
        })
      ])

      @canvas.appendNode node
      @initNode node, m.x(), m.y()
      node

    labelWidth : (width)-> CanvasElement.prototype.labelWidth.call(this, width) - 20
    # Update the svg element
    render : ()->
      CanvasManager.setLabel @, @$el.children(".node-label")

  }
