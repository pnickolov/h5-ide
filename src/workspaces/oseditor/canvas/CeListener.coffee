
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsListener"
    ### env:dev:end ###
    type : constant.RESTYPE.OSLISTENER

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [8,8]

    portPosMap : {
      "listener" : [ 72, 35, CanvasElement.constant.PORT_RIGHT_ANGLE, 80, 35 ]
    }

    events :
      "mousedown .fip-status"          : "toggleFip"

    listenModelEvents : ()->
      @listenTo @model, 'change:fip', @render
      return

    toggleFip : ()->
      if @canvas.design.modeIsApp() then return false

      hasFloatingIp = !!@model.getFloatingIp()
      @model.setFloatingIp(!hasFloatingIp)

      CanvasManager.updateFip @$el.children(".fip-status"), @model
      false

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image  : "ide/icon/openstack/cvs-vip.png"
        imageX : 0
        imageY : 0
        imageW : 80
        imageH : 80
        label  : m.get "name"
      }).add([
        svg.image( "", 12, 14).move(36, 36).classes('fip-status tooltip')
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'listener'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      m = @model
      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")
      # Update FIP
      CanvasManager.updateFip @$el.children(".fip-status"), m
      null

  }
