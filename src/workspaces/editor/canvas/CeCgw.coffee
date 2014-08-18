
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js", "CloudResources" ], ( CanvasElement, constant, CanvasManager, lang, CloudResources )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeCgw"
    ### env:dev:end ###
    type : constant.RESTYPE.CGW

    parentType  : ["SVG"]
    defaultSize : [17, 10]

    portPosMap : {
      "cgw-vpn" : [ 6, 45, CanvasElement.constant.PORT_LEFT_ANGLE ]
    }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/cvs-cgw.png"
        imageX  : 13
        imageY  : 8
        imageW  : 151
        imageH  : 76
      }).add([
        svg.text("").move(100, 95).classes('node-label')

        svg.use("port_right").attr({
          'class'        : 'port port-purple tooltip'
          'data-name'    : 'cgw-vpn'
          'data-tooltip' : lang.ide.PORT_TIP_I
        })
      ])

      # Create State Icon
      if not m.design().modeIsStack() and m.get("appId")
        appData = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
        state = appData?.get('state') or 'unknown'
        svgEl.add svg.circle(8).move(159, 7).attr({
          'class': "res-state tooltip #{state}"
          'data-tooltip': state
        })


      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    # Update the svg element
    render : ()->
      CanvasManager.update @$el.children(".node-label"), @model.get("name")
  }
