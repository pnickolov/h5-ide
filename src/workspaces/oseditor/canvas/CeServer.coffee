
define [
  "CanvasElement"
  "constant"
  "CanvasManager"
  "i18n!/nls/lang.js"
], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsServer"
    ### env:dev:end ###
    type : constant.RESTYPE.OSSERVER

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "port" : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "pool" : [ 80, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/cvs-instance.png"
        imageX  : 15
        imageY  : 11
        imageW  : 61
        imageH  : 62
        label   : true
        labelBg : true
      }).add([
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'port'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'pool'
          'data-tooltip' : lang.IDE.PORT_TIP_E
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    render : ()->
      CanvasManager.setLabel @, @$el.children(".node-label")
  }

