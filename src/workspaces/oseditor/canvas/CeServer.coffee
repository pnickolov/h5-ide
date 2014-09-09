
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
      "pool"   : [ 5, 30, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "server" : [ 82, 30, CanvasElement.constant.PORT_RIGHT_ANGLE, 85,30 ]
    }

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/openstack/cvs-server.png"
        imageX  : 0
        imageY  : 0
        imageW  : 90
        imageH  : 90
        label   : true
        labelBg : true
      }).add([
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'server'
          'data-tooltip' : lang.IDE.PORT_TIP_E
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    render : ()->
      CanvasManager.setLabel @, @$el.children(".node-label")
  }

