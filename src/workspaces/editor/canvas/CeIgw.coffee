
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js", "Design", "CloudResources" ], ( CanvasElement, constant, CanvasManager, lang, Design, CloudResources )->

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
          'data-tooltip' : lang.ide.PORT_TIP_C
        })
      )

      # Create State Icon
      if not m.design().modeIsStack() and m.get("appId")
        appData = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
        state = appData?.get('state') or 'unknown'
        svgEl.add svg.circle(8).move(63, 15).attr({
          'class': "res-state tooltip #{state}"
          'data-tooltip': state
        })

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl
  }
