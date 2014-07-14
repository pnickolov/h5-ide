
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeInstance"
    ### env:dev:end ###
    type : constant.RESTYPE.INSTANCE

    parentType  : [ constant.RESTYPE.AZ, constant.RESTYPE.SUBNET, constant.RESTYPE.ASG ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "instance-sg-left"  : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "instance-sg-right" : [ 80, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "instance-attach"   : [ 78, 50, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "instance-rtb"      : [ 45, 2,  CanvasElement.constant.PORT_UP_ANGLE  ]
    }
    portDirMap : {
      "instance-sg" : "horizontal"
    }

    iconUrl : ()->
      ami = @model.getAmi() || @model.get("cachedAmi")

      if not ami
        "ide/ami/ami-not-available.png"
      else
        "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/instance-canvas.png"
        imageX  : 15
        imageY  : 11
        imageW  : 61
        imageH  : 62
        label   : true
        labelBg : true
        sg      : true
      }).add([
        # Ami Icon
        svg.image( MC.IMG_URL + @iconUrl(), 39, 27 ).move(30, 15).classes("ami-image")
        # Volume Image
        svg.image( "", 29, 24 ).move(21, 46).classes('volume-image')
        # Volume Label
        svg.text( "" ).move(36, 58).classes('volume-number')
        # Eip
        svg.image( "", 12, 14).move(53, 49).classes('eip-status tooltip')

        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'instance-sg'
          'data-alias'   : 'instance-sg-left'
          'data-tooltip' : lang.ide.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'instance-attach'
          'data-tooltip' : lang.ide.PORT_TIP_E
        })
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'instance-sg'
          'data-alias'   : 'instance-sg-right'
          'data-tooltip' : lang.ide.PORT_TIP_D
        })
        svg.use("port_bottom").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'instance-rtb'
          'data-tooltip' : lang.ide.PORT_TIP_C
        })

        # Servergroup
        svg.group().add([
          svg.rect(20,14).move(36,2).radius(3).classes("server-number-bg")
          svg.plain("0").move(46,13).classes("server-number")
        ]).classes("server-number-group")
      ])

      if not @model.design().modeIsStack() and m.get("appId")
        svgEl.add(
          svg.circle(10).move(68, 15).classes('instance-state unknown')
        )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      m = @model

      # Update label
      CanvasManager.update @$el.children(".node-label"), m.get("name")

      # Update Image
      CanvasManager.update @$el.children(".ami-image"), @iconUrl(), "href"


      if not @model.design().modeIsStack() and m.get("appId")
        # Update Instance State in app
        @updateAppState()

      # Update Server number
      numberGroup = @$el.children(".server-number-group")
      if m.get("count") > 1
        CanvasManager.toggle @$el.children(".instance-state"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), m.get("count")
      else
        CanvasManager.toggle @$el.children(".instance-state"), true
        CanvasManager.toggle numberGroup, false

      # Update EIP
      CanvasManager.updateEip @$el.children(".eip-status"), m

      # Update Volume
      volumeCount = if m.get("volumeList") then m.get("volumeList").length else 0
      if volumeCount > 0
        volumeImage = 'ide/icon/instance-volume-attached-normal.png'
      else
        volumeImage = 'ide/icon/instance-volume-not-attached.png'
      CanvasManager.update @$el.children(".volume-image"), volumeImage, "href"
      CanvasManager.update @$el.children(".volume-number"), volumeCount

  }, {
    isDirectParentType : ( t )-> return t isnt constant.RESTYPE.AZ

    createResource : ( type, attr, option )->
      if not attr.parent then return
      if attr.parent.type is constant.RESTYPE.SUBNET
        return CanvasElement.createResource( type, attr, option )
      else if attr.parent.type is constant.RESTYPE.ASG
        return CanvasElement.createResource( constant.RESTYPE.LC, attr, option )
      else if attr.parent.type is constant.RESTYPE.AZ
        # Auto add subnet for instance
        attr.parent = CanvasElement.createResource( constant.RESTYPE.SUBNET, {
          x      : attr.x + 1
          y      : attr.y + 1
          width  : 11
          height : 11
          parent : attr.parent
        } , option )

        attr.x += 2
        attr.y += 2

        return CanvasElement.createResource( constant.RESTYPE.INSTANCE, attr, option )

  }

