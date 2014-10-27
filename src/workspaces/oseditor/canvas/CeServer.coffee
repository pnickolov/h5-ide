
define [
  "CanvasElement"
  "constant"
  "CanvasManager"
  "i18n!/nls/lang.js"
  "CloudResources"
  "./CpVolume"
], ( CanvasElement, constant, CanvasManager, lang, CloudResources, VolumePopup )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsServer"
    ### env:dev:end ###
    type : constant.RESTYPE.OSSERVER

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [ 8, 8 ]

    portPosMap : {
      "pool-left"    : [ 0,  40, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "pool-right"   : [ 80, 40, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "server-left"  : [ 0,  60, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "server-right" : [ 80, 60, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }
    portDirMap : {
      "pool"   : "horizontal"
      "server" : "horizontal"
    }

    events :
      "mousedown .fip-status" : "toggleFip"
      "mousedown .vol-image"  : "showVolume"
      "click .fip-status"     : "suppressEvent"
      "click .vol-image"      : "suppressEvent"

    suppressEvent : ()-> false

    iconUrl : ()->
      image = @model.getImage() || @model.get("cachedAmi")

      if not image
        m = @model
        server = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
        if server
          server = server.attributes
          if server.platform and server.platform is "windows"
            url = "ide/ami-os/windows.#{server.architecture}@2x.png"
          else
            url = "ide/ami-os/linux.#{server.architecture}@2x.png"
        else
          url = "ide/ami-os/image-not-available.png"
      else
        url = "ide/ami-os/#{image.os_type}.#{image.architecture}@2x.png"
      url

    listenModelEvents : ()->
      @listenTo @model, "change:imageId", @render
      @listenTo @model, 'change:fip', @render
      @listenTo @canvas, "change:externalData", @updateState
      return

    updateState: ->
      m = @model
      stateIcon  = @$el.children(".res-state")

      if stateIcon
        appData = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
        state    = appData?.get("status") || "unknown"
        stateIcon.data("tooltip", state).attr("data-tooltip", state).attr("class", "res-state tooltip #{state}")

    toggleFip : ()->
      if @canvas.design.modeIsApp() then return false
      embedPort = @model.embedPort()
      hasFloatingIp = !!embedPort.getFloatingIp()
      embedPort.setFloatingIp(!hasFloatingIp)

      CanvasManager.updateFip @$el.children(".fip-status"), @model

      false


    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createRawNode().add([

        svg.use("os_server")

        # Image Icon
        svg.image( MC.IMG_URL + @iconUrl(), 30, 30 ).move(25, 10).classes("ami-image tooltip")
        .attr('data-tooltip': @model.getImage().name)

        # FIP
        svg.group().move(43, 50).classes("fip-status cvs-hover tooltip").add([
          svg.image("").size(26,21).classes("normal")
          svg.image("").size(26,21).classes("hover")
        ])

        # Volume
        svg.group().move(15, 46).classes("vol-image cvs-hover tooltip").add([
          svg.image("").size(22,26).classes("normal")
          svg.image("").size(22,26).classes("hover")
        ])
        svg.plain("").move(26, 60).classes('volume-number')

        @createPortElement().attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-alias'   : 'pool-left'
          'data-tooltip' : lang.IDE.PORT_TIP_O
        })

        @createPortElement().attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-alias'   : 'pool-right'
          'data-tooltip' : lang.IDE.PORT_TIP_O
        })

        @createPortElement().attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'server'
          'data-alias'   : 'server-left'
          'data-tooltip' : lang.IDE.PORT_TIP_N
        })

        @createPortElement().attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'server'
          'data-alias'   : 'server-right'
          'data-tooltip' : lang.IDE.PORT_TIP_N
        })
      ])
      if not m.design().modeIsStack() and m.get("appId")
        svgEl.add( svg.circle(8).move(63, 15).classes('res-state unknown') )
      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      @listenTo @model, 'change:volume', @updateVolume
      svgEl

    render : ()->
      m = @model
      # Update Label
      CanvasManager.setLabel @, @$el.children(".node-label")
      # Update Image
      CanvasManager.update @$el.children(".ami-image"), @iconUrl(), "href"
      # Update FIP
      CanvasManager.updateFip @$el.children(".fip-status"), m

      @updateVolume()
      @updateState()
      null

    updateVolume: ->
      m = @model
      volumes = m.volumes()
      @$el.children('.volume-number').text(volumes.length || 0)

      if volumes.length is 0
        img1 = 'ide/icon-os/cvs-vol-e-n.png'
        img2 = 'ide/icon-os/cvs-vol-e-h.png'
      else
        img1 = 'ide/icon-os/cvs-vol-ne-n.png'
        img2 = 'ide/icon-os/cvs-vol-ne-h.png'

      $vol = @$el.children(".vol-image")
      CanvasManager.update( $vol.find(".normal"), img1, "href" )
      CanvasManager.update( $vol.find(".hover"),  img2, "href" )
      return


    showVolume : ()->
      owner = @model

      v = owner.volumes()[0]
      attachment = @$el[0]
      canvas = @canvas

      new VolumePopup {
        attachment    : attachment
        host          : owner
        models        : owner.volumes()
        canvas        : canvas
        selectAtBegin : v
      }
      return
  }

