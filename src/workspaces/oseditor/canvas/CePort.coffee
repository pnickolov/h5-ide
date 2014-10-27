
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
      svgEl = @createRawNode().add([

        svg.use("os_port")

        # FIP
        svg.group().move(33, 29).classes("fip-status tooltip").add([
          svg.image("").size(26,21).classes("normal")
          svg.image("").size(26,21).classes("hover")
        ])

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
