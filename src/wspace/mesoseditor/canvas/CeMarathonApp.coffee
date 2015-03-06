
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js", "CanvasView" ], ( CanvasElement, constant, CanvasManager, lang, CanvasView )->

  PREDEF_APP_COLORS = ['#f26c4f', '#7dc476', '#00bef2', '#615ca8', '#fcec00', '#ff9900', '#ffcc00', '#ffcc99', '#ff99ff', '#00cccc', '#99cc99', '#9999ff', '#ffff99', '#ff00ff', '#663300', '#336600', '#660066', '#003300', '#0000ff', '#666600']

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeMarathonApp"
    ### env:dev:end ###
    type : constant.RESTYPE.MRTHAPP

    parentType  : [ constant.RESTYPE.MRTHGROUP, "SVG" ]
    defaultSize : [ 18, 8 ]

    portPosMap : {
      "app-dep-in"  : [ 5,   38, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "app-dep-out" : [ 170, 38, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    initialize : ()->
      this.color = PREDEF_APP_COLORS[ Math.round(Math.random()*PREDEF_APP_COLORS.length) ]
      CanvasElement.prototype.initialize.apply this, arguments

    iconUrl : ()-> "ide/ami/ami-not-available.png"

    listenModelEvents : ()->
      # @listenTo @model, "change:cidr", @render
      return

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      size = @size()

      width    = 150
      height   = 70
      portSize = 10

      # Call parent's createNode to do basic creation
      svgEl = svg.group().add([
        svg.rect( width + 9, height + 9 ).move( 8.5, 0.5 ).radius(5).classes("marathon-app-bg")
        svg.rect( width-1, 37 ).move( portSize + 3.5, 37.5 ).radius(2).classes("marathon-app-bottom")
        svg.rect( width-1, 32 ).move( portSize + 3.5, 9.5 ).classes("marathon-app-top")
        svg.rect( width-2, 1  ).move( portSize + 4, 41 ).classes("marathon-app-line")
        svg.use( "marathon_app_title" ).attr({
          "class" : "marathon-app-ceiling"
          "fill"  : @color
        })

        svg.image( MC.IMG_URL + @iconUrl(), 32, 32 ).move( 20, 20 )

        svg.text("").move(45, 29).classes('node-label')

        svg.image( MC.IMG_URL + @iconUrl(), 32, 32 ).move( 20, 50 )

        svg.text("123").move(45, 29).classes('cpu-label')
        svg.text("245").move(45, 29).classes('memory-label')

        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'app-dep-in'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'app-dep-out'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })

        # Servergroup
        svg.group().add([
          svg.rect(20,16).move(155,-3).radius(3).classes("server-number-bg")
          svg.plain("0").move(165,9).attr({
            "class" : "server-number"
            "text-anchor" : "middle"
          })
        ]).classes("server-number-group")

      ]).attr({ "data-id" : @cid }).classes( 'canvasel ' + @type.replace(/\.|:/g, "-") )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    label : ()-> @model.get('name')
    labelWidth : ()-> 110

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      CanvasManager.setLabel @, @$el.children(".node-label")
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH
  }
