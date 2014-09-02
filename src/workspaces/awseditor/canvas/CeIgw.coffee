
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js", "Design", "CloudResources" ], ( CanvasElement, constant, CanvasManager, lang, Design, CloudResources )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeIgw"
    ### env:dev:end ###
    type : constant.RESTYPE.IGW

    parentType  : [ constant.RESTYPE.VPC ]
    defaultSize : [8,8]

    portPosMap : {
      "igw-tgt" : [ 78, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    sticky : "left"

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/cvs-igw.png"
        imageX  : 10
        imageY  : 16
        imageW  : 60
        imageH  : 46
        label   : m.get("name")
      }).add(
        svg.use("port_left").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'igw-tgt'
          'data-tooltip' : lang.IDE.PORT_TIP_C
        })
      )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl
  }
