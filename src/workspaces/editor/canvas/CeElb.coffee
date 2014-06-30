
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeElb"
    ### env:dev:end ###
    type : constant.RESTYPE.ELB

    portPosMap : {
      "elb-sg-in"  : [ 2,  35, CanvasElement.constant.PORT_LEFT_ANGLE  ]
      "elb-assoc"  : [ 79, 50, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "elb-sg-out" : [ 79, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    iconUrl : ()->
      if @model.get("internal")
        "ide/icon/elb-internal-canvas.png"
      else
        "ide/icon/elb-internet-canvas.png"

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image  : @iconUrl()
        imageX : 9
        imageY : 11
        imageW : 70
        imageH : 53
        label  : m.get "name"
        sg     : true
      }).add([
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'elb-sg-in'
          'data-tooltip' : lang.ide.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-gray tooltip'
          'data-name'    : 'elb-assoc'
          'data-tooltip' : lang.ide.PORT_TIP_K
        })
        svg.use("port_right").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'elb-sg-out'
          'data-tooltip' : lang.ide.PORT_TIP_J
        })
      ])

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      m = @model
      # Update label
      CanvasManager.update @$el.children(".node-label"), m.get("name")
      # Update Image
      CanvasManager.update @$el.children("image"), @iconUrl(), "href"
      # Toggle left port
      CanvasManager.toggle @$el.children(".port-elb-sg-in"), m.get("internal")
  }
