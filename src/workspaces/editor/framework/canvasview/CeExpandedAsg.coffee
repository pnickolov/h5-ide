
define [ "./CanvasElement", "constant", "CanvasManager", "./CeAsg", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, CeAsg, lang )->

  CeExpandedAsg = ()->
    CanvasElement.apply( this, arguments )
    this.type = constant.RESTYPE.ASG
    null

  CanvasElement.extend( CeExpandedAsg, "ExpandedAsg" )
  ChildElementProto = CeExpandedAsg.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "launchconfig-sg-left"  : [ 30,  50, CanvasElement.constant.PORT_LEFT_ANGLE ]
    "launchconfig-sg-right" : [ 100, 50, CanvasElement.constant.PORT_RIGHT_ANGLE ]
  }
  ChildElementProto.portDirMap = {
    "launchconfig-sg" : "horizontal"
  }

  ChildElementProto.select = ()->
    m = @model.get("originalAsg")
    @doSelect( @type, m.id, @id )
    true

  ChildElementProto.amiIconUrl = ()->
    lc = @model.get("originalAsg").get("lc")
    if lc and lc.getCanvasView()
      lc.getCanvasView().iconUrl()
    else
      "ide/ami/ami-not-available.png"

  ChildElementProto.draw = ( isCreate ) ->

    $("##{@id}").remove()

    m = @model
    originalAsg = m.get("originalAsg")

    label   = originalAsg.get("name")
    lc      = originalAsg.get("lc")

    x      = m.x()
    y      = m.y()
    width  = m.width()  * MC.canvas.GRID_WIDTH
    height = m.height() * MC.canvas.GRID_HEIGHT

    members = [
      Canvon.rectangle( 1, 1, width - 1, height - 1 ).attr({
        'class':'group group-asg', 'rx':5, 'ry':5
      }),

      # title bg
      Canvon.path( CeAsg.prototype.PATH_ASG_TITLE ).attr({'class':'asg-title'}),

      # title
      Canvon.text( 4, 14, label ).attr({'class':'group-label'})

    ]

    if lc
      lcLabel = lc.get("name")
      members = members.concat [
        # lc icon
        Canvon.image( MC.IMG_URL + "ide/icon/instance-canvas.png", 35, 39, 61, 62 ),
        Canvon.image( MC.IMG_URL + @amiIconUrl(), 50, 45, 39, 27 ).attr({"class":'ami-icon'}),

        # lc label
        Canvon.text( 65, 116, lcLabel ).attr({'class':'node-label'}),

        # left port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class' : 'port port-blue port-launchconfig-sg port-launchconfig-sg-left tooltip'
          'data-name'      : 'launchconfig-sg'
          'data-alias'     : 'launchconfig-sg-left'
          'data-position'  : 'left'
          'data-type'      : 'sg'
          'data-direction' : 'in'
          'data-tooltip'   : lang.ide.PORT_TIP_D
        }),

        # right port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class' : 'port port-blue port-launchconfig-sg port-launchconfig-sg-right tooltip'
          'data-name'      : 'launchconfig-sg'
          'data-alias'     : 'launchconfig-sg-right'
          'data-position'  : 'right'
          'data-type'      : 'sg'
          'data-direction' : 'out'
          'data-tooltip'   : lang.ide.PORT_TIP_D
        })
      ]

    node = Canvon.group().append.apply( Canvon.group(), members ).attr({
      'id'         : @id
      'class'      : 'dragable AWS-AutoScaling-Group asg-expand'
      'data-type'  : 'group'
      'data-class' : @type
    })

    # Move the node to right place
    @getLayer("asg_layer").append node
    @initNode node, m.x(), m.y()


  null
