
define [ "event", "./CanvasElement", "i18n!nls/lang.js", "constant", "Design", "CanvasManager" ], ( ide_event, CanvasElement, lang, constant, Design, CanvasManager )->


  CeAsg = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeAsg, constant.RESTYPE.ASG )

  CeAsgProto = CeAsg.prototype

  CeAsgProto.PATH_ASG_TITLE = "M0 21l0 -16a5 5 0 0 1 5 -5l121 0a5 5 0 0 1 5 5l0 16z"

  CeAsgProto.isRemovable = ()->
    asg = @model
    lc = asg.get 'lc'

    if not lc or lc.__brothers.length > 0 or lc.isClone()
      true
    else
      asgName = asg.get 'name'
      lcName = lc.get 'name'
      sprintf lang.ide.CVS_CFM_DEL_ASG, lcName, asgName, asgName, lcName

  CanvasElement.prototype.remove = ()->
    if @model.isRemoved() then return

    res = @isRemovable()
    comp = @model
    comp_name = comp.get("name")

    if _.isString( res )
      # Confirmation
      template = MC.template.canvasOpConfirm {
        title   : sprintf lang.ide.CVS_CFM_DEL, comp_name
        content : res
      }
      modal template, true

      $("#canvas-op-confirm").one "click", ()->
        if not comp.isRemoved()
          comp.remove()
          $canvas.selected_node().length = 0
          ide_event.trigger ide_event.OPEN_PROPERTY
        null

    else if res.error
      # Error
      notification "error", res.error

    else if res is true
      # Do remove
      comp.remove()
      $canvas.selected_node().length = 0
      ide_event.trigger ide_event.OPEN_PROPERTY
      return true

    return false

  CeAsgProto.asgExpand = ( parentId, x, y )->
    design = @model.design()

    # This method contains some logic to determine if the ASG is expanded
    comp   = @model
    target = design.component(parentId)

    if target
      ExpandedAsgModel = Design.modelClassForType( "ExpandedAsg" )
      res = new ExpandedAsgModel({
        x : x
        y : y
        originalAsg : comp
        parent : target
      })

    if res and res.id
      return true

    targetName = if target.type is "AWS.EC2.AvailabilityZone" then target.get("name") else target.parent().get("name")
    notification 'error', sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, comp.get("name"), targetName

    return false

  CeAsgProto.draw = ( isCreate )->

    m = @model

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
        Canvon.path( this.PATH_ASG_TITLE ).attr({'class':'asg-title'})
      )

      node.append(
        # dragger
        Canvon.image(MC.IMG_URL + 'ide/icon/asg-resource-dragger.png', width - 21, 0, 22, 21).attr({
          'class'        : 'asg-resource-dragger tooltip'
          'data-tooltip' : 'Expand the group by drag-and-drop in other availability zone.'
        })
      )

      node.append(
        # prompt
        Canvon.group().append(
          Canvon.text(25, 45,  'Drop AMI from'),
          Canvon.text(20, 65,  'resource panel to'),
          Canvon.text(30, 85,  'create launch'),
          Canvon.text(30, 105, 'configuration')
        ).attr({ 'class' : 'prompt_text'}),

        # title
        Canvon.text( 4, 14, MC.truncate(m.get("name"), 15) ).attr({'class':'group-label'})

      ).attr({
        'id'         : @id
        'class'      : 'dragable AWS-AutoScaling-Group'
        'data-type'  : 'group'
        'data-class' : @type
      })

      # Move the node to right place
      @getLayer("asg_layer").append node
      CanvasManager.position node, m.x(), m.y()

    else
      node = @$element()
      CanvasManager.update( node.children(".group-label"), MC.truncate(m.get("name"), 15) )
      @__drawExpandedAsg()


    hasLC = !!m.get("lc")
    CanvasManager.toggle( node.children(".prompt_text"), !hasLC )
    null

  CeAsgProto.__drawExpandedAsg = ->
    for asg in @model.get("expandedList")
      asg.draw()
    null

  CeAsg
