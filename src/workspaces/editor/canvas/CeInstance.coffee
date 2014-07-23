
define [
  "./CanvasElement"
  "constant"
  "./CanvasManager"
  "./CpVolume"
  "./CpInstance"
  "i18n!/nls/lang.js"
  "CloudResources"
  "event"
], ( CanvasElement, constant, CanvasManager, VolumePopup, InstancePopup, lang, CloudResources, ide_event )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeInstance"
    ### env:dev:end ###
    type : constant.RESTYPE.INSTANCE

    parentType  : [ constant.RESTYPE.AZ, constant.RESTYPE.SUBNET, constant.RESTYPE.ASG, "ExpandedAsg" ]
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

    events :
      "mousedown .eip-status"          : "toggleEip"
      "mousedown .volume-image"        : "showVolume"
      "mousedown .server-number-group" : "showGroup"
      "click .eip-status"              : "suppressEvent"
      "click .volume-image"            : "suppressEvent"
      "click .server-number-group"     : "suppressEvent"

    suppressEvent : ()-> false

    iconUrl : ()->
      ami = @model.getAmi() || @model.get("cachedAmi")

      if not ami
        "ide/ami/ami-not-available.png"
      else
        "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"

    listenModelEvents : ()->
      @listenTo @model, "change:primaryEip", @render
      @listenTo @model, "change:imageId", @render
      @listenTo @model, "change:volumeList", @render
      @listenTo @model, "change:count", @updateServerCount
      return

    updateServerCount : ()->
      @render()
      @canvas.getItem( eni.id )?.render() for eni in @model.connectionTargets( "EniAttachment" )
      return

    toggleEip : ()->
      if @canvas.design.modeIsApp() then return false

      toggle = !@model.hasPrimaryEip()
      @model.setPrimaryEip( toggle )

      if toggle
        Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()

      CanvasManager.updateEip @$el.children(".eip-status"), @model

      ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
      false

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
        svg.image( MC.IMG_URL + @iconUrl(), 39, 27 ).move(27, 15).classes("ami-image")
        # Volume Image
        svg.image( "", 29, 24 ).move(21, 46).classes('volume-image')
        # Volume Label
        svg.text( "" ).move(35, 58).classes('volume-number')
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
        svgEl.add( svg.circle(8).move(63, 14).classes('instance-state unknown') )

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

      # Update Server number
      numberGroup = @$el.children(".server-number-group")
      statusIcon  = @$el.children(".instance-state")
      if m.get("count") > 1
        CanvasManager.toggle statusIcon, false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), m.get("count")

      else
        CanvasManager.toggle statusIcon, true
        CanvasManager.toggle numberGroup, false

        if statusIcon.length
          instance = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
          state    = instance?.get("instanceState").name || "unknown"
          statusIcon.data("tooltip", state).attr("class", "instance-state tooltip #{state}")

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

    showVolume : ()->

      # Only show volume if not in app mode nor servergroup
      if @canvas.design.modeIsApp() and @model.get("count") > 1
        return false

      if @volPopup then return false
      self = @
      @volPopup = new VolumePopup {
        attachment : @$el[0]
        host       : @model
        models     : @model.get("volumeList")
        canvas     : @canvas
        onRemove   : ()-> _.defer ()-> self.volPopup = null; return
      }
      false

    showGroup : ()->
      # Only show server group list in app mode.
      if not @canvas.design.modeIsApp() then return

      insCln = CloudResources( @type, @model.design().region() )
      members = (@model.groupMembers() || []).slice(0)
      members.unshift( { appId : @model.get("appId") } )

      name = @model.get("name")
      gm   = []
      icon = @iconUrl()
      for m, idx in members
        ins = insCln.get( m.appId )
        if not ins
          console.warn "Cannot find instance of `#{m.appId}`"
          continue
        ins = ins.attributes

        volume = ins.blockDeviceMapping.length
        for bdm in ins.blockDeviceMapping
          if bdm.deviceName is ins.rootDeviceName
            --volume
            break

        gm.push {
          name   : "#{name}-#{idx}"
          id     : m.appId
          icon   : icon
          volume : volume
          state  : ins.instanceState?.name || "unknown"
        }

      new InstancePopup {
        attachment : @$el[0]
        host       : @model
        models     : gm
        canvas     : @canvas
      }
      return

  }, {
    isDirectParentType : ( t )-> return t isnt constant.RESTYPE.AZ

    createResource : ( type, attr, option )->
      if not attr.parent then return

      switch attr.parent.type
        when constant.RESTYPE.SUBNET
          return CanvasElement.createResource( type, attr, option )

        when constant.RESTYPE.ASG, "ExpandedAsg"
          TYPE_LC = constant.RESTYPE.LC
          return CanvasElement.getClassByType( TYPE_LC ).createResource( TYPE_LC, attr, option )

        when constant.RESTYPE.AZ
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

      return
  }

