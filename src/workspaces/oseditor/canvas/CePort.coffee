
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js"], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsPort"
    ### env:dev:end ###
    type : constant.RESTYPE.OSPORT

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
        svg.group().move(33, 29).classes("fip-status cvs-hover tooltip").add([
          svg.image("").size(26,21).classes("normal")
          svg.image("").size(26,21).classes("hover")
        ])

        @createPortElement().attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-alias'   : 'pool-left'
          'data-tooltip' : lang.IDE.PORT_TIP_P
        })

        @createPortElement().attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'pool'
          'data-alias'   : 'pool-right'
          'data-tooltip' : lang.IDE.PORT_TIP_P
        })

        @createPortElement().attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'server'
          'data-alias'   : 'server-left'
          'data-tooltip' : lang.IDE.PORT_TIP_R
        })

        @createPortElement().attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'server'
          'data-alias'   : 'server-right'
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
