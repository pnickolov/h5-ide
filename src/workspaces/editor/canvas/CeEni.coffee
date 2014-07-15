
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeEni"
    ### env:dev:end ###
    type : constant.RESTYPE.ENI

    parentType  : [ constant.RESTYPE.SUBNET ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "eni-sg-left"  : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE  ]
      "eni-attach"   : [ 8,  50, CanvasElement.constant.PORT_LEFT_ANGLE  ]
      "eni-sg-right" : [ 80, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "eni-rtb"      : [ 45, 2,  CanvasElement.constant.PORT_UP_ANGLE    ]
    }

    portDirMap : {
      "eni-sg" : "horizontal"
    }

    events :
      "mousedown .eip-status" : "toggleEip"

    iconUrl : ()->
      if @model.connections( "EniAttachment" ).length
        "ide/icon/eni-canvas-attached.png"
      else
        "ide/icon/eni-canvas-unattached.png"

    toggleEip : ()->
      toggle = !@model.hasPrimaryEip()
      @model.setPrimaryEip( toggle )

      if toggle
        Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()

      CanvasManager.updateEip @$el.children(".eip-status"), @model
      false

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : @iconUrl()
        imageX  : 16
        imageY  : 15
        imageW  : 59
        imageH  : 49
        label   : true
        labelBg : true
        sg      : true
      }).add([
        svg.image("", 12, 14).move(44,37).classes('eip-status tooltip')

        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'eni-sg'
          'data-alias'   : 'eni-sg-left'
          'data-tooltip' : lang.ide.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'eni-attach'
          'data-tooltip' : lang.ide.PORT_TIP_G
        })
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'eni-sg'
          'data-alias'   : 'eni-sg-right'
          'data-tooltip' : lang.ide.PORT_TIP_F
        })
        svg.use("port_bottom").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'eni-rtb'
          'data-tooltip' : lang.ide.PORT_TIP_C
        })

        svg.group().add([
          svg.rect(20,14).move(36,2).radius(3).classes("server-number-bg")
          svg.plain("0").move(46,13).classes("server-number")
        ]).classes("server-number-group")
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      m = @model

      # Update label
      CanvasManager.update @$el.children(".node-label"), m.get("name")

      # Update Image
      CanvasManager.update @$el.children("image:not(.eip-status)"), @iconUrl(), "href"

      # Update SeverGroup Count
      count = m.serverGroupCount()

      numberGroup = @$el.children(".server-number-group")
      CanvasManager.toggle @$el.children(".port-eni-rtb"), (count <= 1)
      CanvasManager.toggle numberGroup, (count > 1)
      numberGroup.children("text").text( count )

      # Update EIP
      CanvasManager.updateEip @$el.children(".eip-status"), m
  }
