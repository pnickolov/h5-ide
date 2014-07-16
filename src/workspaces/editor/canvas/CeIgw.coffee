
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js", "Design" ], ( CanvasElement, constant, CanvasManager, lang, Design )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeIgw"
    ### env:dev:end ###
    type : constant.RESTYPE.IGW

    defaultSize : [8,8]

    portPosMap : {
      "igw-tgt" : [ 78, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/igw-canvas.png"
        imageX  : 10
        imageY  : 16
        imageW  : 60
        imageH  : 46
        label   : m.get("name")
      }).add(
        svg.use("port_left").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'igw-tgt'
          'data-tooltip' : lang.ide.PORT_TIP_C
        })
      )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl
  }, {
    createResource : ( type, attr, option )->
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()
      attr.x = vpc.x() - 4
      if attr.y < vpc.y() or attr.y + 8 > vpc.y() + vpc.height()
        attr.y = vpc.y() + Math.round( vpc.height() / 2 ) - 4

      attr.parent = vpc
      CanvasElement.createResource( type, attr, option )
  }
