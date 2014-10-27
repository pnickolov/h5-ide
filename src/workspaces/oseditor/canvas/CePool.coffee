
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsPool"
    ### env:dev:end ###
    type : constant.RESTYPE.OSPOOL

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "elb"  : [ 2,  36, CanvasElement.constant.PORT_LEFT_ANGLE  ]
      "pool" : [ 73, 36, CanvasElement.constant.PORT_RIGHT_ANGLE, 81, 36 ]
    }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createRawNode().add([

        svg.use("os_pool")

        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'elb'
          'data-tooltip' : lang.IDE.PORT_TIP_Q
        })
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'pool'
          'data-tooltip' : lang.IDE.PORT_TIP_R
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")
  }
