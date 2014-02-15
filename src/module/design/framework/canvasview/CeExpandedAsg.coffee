
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
    @doSelect( @type, m.id, @id )
    true

  ChildElementProto.amiIconUrl = ()->
    lc = @model.get("originalAsg").get("lc")
    if lc and lc.getCanvasView()
      lc.getCanvasView().iconUrl()
    else
      "ide/ami/ami-not-available.png"

  ChildElementProto.draw = ( isCreate, isLcCreate ) ->
    m = @model
    originalAsg = m.get("originalAsg")

    label   = originalAsg.get("name")

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
        Canvon.path( MC.canvas.PATH_ASG_TITLE ).attr({'class':'asg-title'}),

        # title
        Canvon.text( 4, 14, label ).attr({'class':'group-label'}),


      ).attr({
        'id'         : @id
        'class'      : 'dragable AWS-AutoScaling-Group asg-expand'
        'data-type'  : 'group'
        'data-class' : @type
      })

      # Move the node to right place
      @getLayer("asg_layer").append node
      @initNode node, m.x(), m.y()

    else
      node = @$element()

      CanvasManager.update( node.children(".group-label"), label )


  null
