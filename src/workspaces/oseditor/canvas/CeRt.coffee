
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsRt"
    ### env:dev:end ###
    type : constant.RESTYPE.OSRT

    parentType  : [ "SVG" ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "route-left"   : [ 0,  40, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "route-right"  : [ 80, 40, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }
    portDirMap : {
      "route"  : "horizontal"
    }

    isPortSignificant : ()-> true

    iconUrl : ()-> "ide/icon/openstack/cvs-router.png"

    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      node = @createRawNode().add([

        svg.use("os_router")

        @createPortElement().attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'route'
          'data-alias'   : 'route-left'
          'data-tooltip' : lang.IDE.PORT_TIP_B
        })

        @createPortElement().attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'route'
          'data-alias'   : 'route-right'
          'data-tooltip' : lang.IDE.PORT_TIP_B
        })
      ])

      @canvas.appendNode node
      @initNode node, m.x(), m.y()
      node

    # Update the svg element
    render : ()-> CanvasManager.setLabel @, @$el.children(".node-label")

  }
