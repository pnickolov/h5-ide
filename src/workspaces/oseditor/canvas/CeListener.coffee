
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsListener"
    ### env:dev:end ###
    type : constant.RESTYPE.OSLISTENER

    parentType  : [ constant.RESTYPE.OSSUBNET ]
    defaultSize : [8,8]

    portPosMap : {
      "elb" : [ 72, 35, CanvasElement.constant.PORT_RIGHT_ANGLE, 80, 35 ]
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
      svgEl = @createRawNode().add([

        svg.use("os_listener")

        # FIP
        svg.group().move(29, 42).classes("fip-status tooltip").add([
          svg.image("").size(26,21).classes("normal")
          svg.image("").size(26,21).classes("hover")
        ])

        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'elb'
          'data-tooltip' : lang.IDE.PORT_TIP_P
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
