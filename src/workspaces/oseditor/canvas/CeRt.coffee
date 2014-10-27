
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsRt"
    ### env:dev:end ###
    type : constant.RESTYPE.OSRT

    parentType  : [ "SVG" ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "external" : [ 10, 30, CanvasElement.constant.PORT_LEFT_ANGLE,  8, 30]
      "route"    : [ 70, 30, CanvasElement.constant.PORT_RIGHT_ANGLE, 72, 30 ]
    }

    isPortSignificant : ()-> true

    iconUrl : ()-> "ide/icon/openstack/cvs-router.png"

    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      node = @createRawNode().add([

        svg.use("os_router")

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

    # Update the svg element
    render : ()-> CanvasManager.setLabel @, @$el.children(".node-label")

  }
