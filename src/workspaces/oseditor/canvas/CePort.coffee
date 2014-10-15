
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js"], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsPort"
    ### env:dev:end ###
    type : constant.RESTYPE.OSPORT

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "pool"   : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE  ]
      "server" : [ 8,  50, CanvasElement.constant.PORT_LEFT_ANGLE  ]
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
      console.assert not @model.isEmbedded()

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/openstack/cvs-port-att.png"
        imageX  : 0
        imageY  : 0
        imageW  : 80
        imageH  : 80
        label   : true
        labelBg : true
      }).add([
        # FIP
        svg.image( "", 12, 14).move(40, 35).classes('fip-status tooltip')
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-tooltip' : lang.IDE.PORT_TIP_P
        })
        svg.use("port_right").attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'server'
          'data-tooltip' : lang.IDE.PORT_TIP_R
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    render : ()->
      m = @model
      CanvasManager.setLabel @, @$el.children(".node-label")
      # Update FIP
      CanvasManager.updateFip @$el.children(".fip-status"), m
      null

  }
