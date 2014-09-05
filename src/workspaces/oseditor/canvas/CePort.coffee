
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js"], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsPort"
    ### env:dev:end ###
    type : constant.RESTYPE.OSPORT

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "server" : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE  ]
      "pool"   : [ 8,  50, CanvasElement.constant.PORT_LEFT_ANGLE  ]
    }

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/cvs-eni-att.png"
        imageX  : 16
        imageY  : 15
        imageW  : 59
        imageH  : 49
        label   : true
        labelBg : true
      }).add([
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'server'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'pool'
          'data-tooltip' : lang.IDE.PORT_TIP_G
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    render : ()->
      CanvasManager.setLabel @, @$el.children(".node-label")
  }
