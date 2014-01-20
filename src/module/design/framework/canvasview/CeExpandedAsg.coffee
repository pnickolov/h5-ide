
define [ "./CanvasElement", "constant", "CanvasManager" ], ( CanvasElement, constant, CanvasManager )->

  ChildElement = ()->
    CanvasElement.apply( this, arguments )
    this.type = constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
    null

  CanvasElement.extend( ChildElement, "ExpandedAsg" )
  ChildElementProto = ChildElement.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "launchconfig-sg-left"  : [ 30,  50, MC.canvas.PORT_LEFT_ANGLE ]
    "launchconfig-sg-right" : [ 100, 50, MC.canvas.PORT_RIGHT_ANGLE ]
  }
  ChildElementProto.portDirMap = {
    "launchconfig-sg" : "horizontal"
  }

  ChildElementProto.select = ()->
    m = @model.get("originalAsg")
    @doSelect( m.type, m.id, @model.id )
    true

  ChildElementProto.amiIconUrl = ()->
    lc = @model.get("originalAsg").get("lc")
    if lc and lc.getCanvasView()
      lc.getCanvasView().iconUrl()
    else
      "ide/ami/ami-not-available.png"

  ChildElementProto.draw = ( isCreate ) ->
    m = @model
    originalAsg = m.get("originalAsg")

    label   = originalAsg.get("name")
    lcLabel = originalAsg.get("lc").get("name")

    if isCreate

      x      = m.x()
      y      = m.y()
      width  = m.width()  * MC.canvas.GRID_WIDTH
      height = m.height() * MC.canvas.GRID_HEIGHT

      node = Canvon.group().append(

        Canvon.rectangle( 1, 1, width - 1, height - 1 ).attr({
          'class':'group group-asg', 'rx':5, 'ry':5
        }),

        # title bg
        Canvon.path( MC.canvas.PATH_ASG_TITLE ).attr({'class':'asg-title'})

        # title
        Canvon.text( 4, 14, label ).attr({'class':'group-label'})

        # lc icon
        Canvon.image( MC.IMG_URL + "ide/icon/instance-canvas.png", 35, 39, 61, 62 )
        Canvon.image( MC.IMG_URL + @amiIconUrl(), 50, 45, 39, 27 ).attr({"class":'ami-icon'})

        # lc label
        Canvon.text( 65, 116, lcLabel ).attr({'class':'node-label'})

        # left port(blue)
        Canvon.path(MC.canvas.PATH_PORT_DIAMOND).attr({
          'class' : 'port port-blue port-launchconfig-sg port-launchconfig-sg-left'
          'data-name'      : 'launchconfig-sg'
          'data-alias'     : 'launchconfig-sg-left'
          'data-position'  : 'left'
          'data-type'      : 'sg'
          'data-direction' : 'in'
        }),

        # right port(blue)
        Canvon.path(MC.canvas.PATH_PORT_DIAMOND).attr({
          'class' : 'port port-blue port-launchconfig-sg port-launchconfig-sg-right'
          'data-name'      : 'launchconfig-sg'
          'data-alias'     : 'launchconfig-sg-right'
          'data-position'  : 'right'
          'data-type'      : 'sg'
          'data-direction' : 'out'
        })

      ).attr({
        'id'         : m.id
        'class'      : 'dragable AWS-AutoScaling-Group asg-expand'
        'data-type'  : 'group'
        'data-class' : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
      })

      # Move the node to right place
      $("#asg_layer").append node
      @initNode node, m.x(), m.y()

    else
      node = @element()

      CanvasManager.update( node.children(".group-label"), label )
      CanvasManager.update( node.children(".node-label"), lcLabel )
      CanvasManager.update( node.children(".ami-icon"), @amiIconUrl(), "href" )

  null
