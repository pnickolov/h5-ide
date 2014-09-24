
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
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "pool"   : [ 5, 36, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "server" : [ 82, 36, CanvasElement.constant.PORT_RIGHT_ANGLE, 85,36 ]
    }

    events :
      "mousedown .fip-status"   : "toggleFip"
      "mousedown .volume-image" : "showVolume"
      "click .volume-image"     : "suppressEvent"

    suppressEvent : ()-> false

    iconUrl : ()->
      image = @model.getImage() || @model.get("cachedAmi")

      if not image
        m = @model
        server = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
        if server
          server = server.attributes
          if server.platform and server.platform is "windows"
            url = "ide/ami/openstack/windows.#{server.architecture}.png"
          else
            url = "ide/ami/openstack/linux-other.#{server.architecture}.png"
        else
          url = "ide/ami/openstack/image-not-available.png"
      else
        url = "ide/ami/openstack/#{image.os_type}.#{image.architecture}.png"
      url

    listenModelEvents : ()->
      @listenTo @model, "change:imageId", @render
      return

    toggleFip : ()->
      if @canvas.design.modeIsApp() then return false

      #toggle = !@model.hasPrimaryEip()
      #@model.setPrimaryEip( toggle )

      # if toggle
      #   Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()

      CanvasManager.updateFip @$el.children(".fip-status"), @model

      # ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
      false


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
        # Image Icon
        svg.image( MC.IMG_URL + @iconUrl(), 39, 27 ).move(27, 15).classes("ami-image")
        # FIP
        svg.image( "", 12, 14).move(50, 55).classes('fip-status tooltip')
        svg.image( MC.IMG_URL+ "ide/icon/icn-vol.png", 29, 24 ).move(22, 52).classes('volume-image')
        svg.text( "" ).move(36, 42).classes('volume-number')
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
      null

    updateVolume: ->
      m = @model
      volumes = m.volumes()
      @$el.children('.volume-number').find('tspan').text(volumes.length || 0)

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

