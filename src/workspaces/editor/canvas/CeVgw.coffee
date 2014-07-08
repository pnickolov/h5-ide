
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeVgw"
    ### env:dev:end ###
    type : constant.RESTYPE.VGW
    defaultSize : [8,8]

    portPosMap : {
      "vgw-tgt" : [ 3,  35, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "vgw-vpn" : [ 70, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/vgw-canvas.png"
        imageX  : 10
        imageY  : 16
        imageW  : 60
        imageH  : 46
        label   : m.get("name")
      }).add([
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'vgw-tgt'
          'data-tooltip' : lang.ide.PORT_TIP_C
        })

        svg.use("port_right").attr({
          'class'        : 'port port-purple tooltip'
          'data-name'    : 'vgw-vpn'
          'data-tooltip' : lang.ide.PORT_TIP_H
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl
  }, {
    createResource : ( type, attr, option )->
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()
      attr.x = vpc.x() + vpc.width() - 4
      if attr.y < vpc.y() or attr.y + 8 > vpc.y() + vpc.height()
        attr.y = vpc.y() + Math.round( vpc.height() / 2 ) - 4

      attr.parent = vpc
      CanvasElement.createResource( type, attr, option )
  }
