
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsPool"
    ### env:dev:end ###
    type : constant.RESTYPE.OSPOOL

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "pool-left"  : [ 0,  40, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "pool-right" : [ 80, 40, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "elb-left"   : [ 0,  60, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "elb-right"  : [ 80, 60, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }
    portDirMap : {
      "elb"  : "horizontal"
      "pool" : "horizontal"
    }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createRawNode().add([

        svg.use("os_pool")

        @createPortElement().attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-alias'   : 'pool-left'
          'data-tooltip' : lang.IDE.PORT_TIP_R
        })

        @createPortElement().attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-alias'   : 'pool-right'
          'data-tooltip' : lang.IDE.PORT_TIP_R
        })

        @createPortElement().attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'elb'
          'data-alias'   : 'elb-left'
          'data-tooltip' : lang.IDE.PORT_TIP_Q
        })

        @createPortElement().attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'elb'
          'data-alias'   : 'elb-right'
          'data-tooltip' : lang.IDE.PORT_TIP_Q
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")
  }
