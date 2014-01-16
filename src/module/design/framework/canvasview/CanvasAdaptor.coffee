define [ "./CanvasElement", "event", 'i18n!nls/lang.js', "constant" ], ( CanvasElement, ide_event, lang, constant )->

  Design = null

  ### $canvas is a adaptor for MC.canvas.js ###
  $canvas = ( id, defaultType )->
    component = Design.__instance.component(id)
    if not component
      component = { id : id, type : defaultType }
      quick = true

    if component.node_line
      new CanvasElement.line( component )
    else if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance or component.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      new CanvasElement.instance( component, quick )
    else
      new CanvasElement( component, quick )

  $canvas.platform = ()-> Design.instance().type()

  $canvas.size = ( w, h )->
    if Design.__instance
      return Design.__instance.canvas.size( w, h )
    else
      return [240, 240]

  $canvas.scale         = ( ratio )-> Design.__instance.canvas.scale( ratio )
  $canvas.offset        = ()-> $(document.getElementById("svg_canvas")).offset()
  $canvas.selected_node = ()-> Design.__instance.canvas.selectedNode
  $canvas.lineStyle     = (ls)->
    if ls is undefined
      if Design.__instance
        return Design.__instance.canvas.lineStyle
      else
        return 0

    Design.__instance.canvas.lineStyle = ls

    if Design.__instance.shouldDraw()
      # Update SgLine
      _.each Design.modelClassForType("SgRuleLine").allObjects(), ( cn )->
        cn.draw()
    null

  $canvas.node = ()->
    nodes = []

    for id, comp of Design.__instance.__canvasNodes
      if not comp.isVisual or comp.isVisual()
        nodes.push( new CanvasElement( comp ) )
    nodes

  $canvas.group  = ()->
    _.map Design.__instance.__canvasGroups, ( comp )->
      new CanvasElement( comp )

  $canvas.clearSelected = ()->
    MC.canvas.event.clearSelected()
    ide_event.trigger ide_event.OPEN_PROPERTY
    null

  $canvas.trigger = ( event )->
    console.assert( _.isString( event ), "Invalid parameter : event " )

    if CanvasEvent[event]
      CanvasEvent[event].apply( this, Array.prototype.slice.call(arguments, 1) )
    null

  $canvas.add = ( type, attributes, pos )->

    attributes = $.extend { x : pos.x, y : pos.y }, attributes
    parent = Design.__instance.component( attributes.groupUId )

    attributes.parent = parent
    delete attributes.groupUId

    if parent and parent.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
      attributes.x = parent.x() + 2
      attributes.y = parent.y() + 3
      type = constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

    Model = Design.modelClassForType type

    createOption = { createByUser : true }
    m = new Model( attributes, createOption )

    ####
    # Quick hack to allow user to select another item,
    # instead of the newly created one.
    ####
    if createOption.selectId
      $canvas( createOption.selectId, true ).select()
    else if m.id
      $canvas( m.id, true ).select()

    return m.id

  $canvas.connect = ( p1, p1Name, p2, p2Name )->
    C = Design.modelClassForPorts( p1Name, p2Name )

    console.assert( C, "Cannot found Class for type: #{p1Name}>#{p2Name}" )

    comp1 = Design.instance().component( p1 )
    comp2 = Design.instance().component( p2 )

    res = C.isConnectable( comp1, comp2 )

    DefaultCreateOption = { createByUser : true }

    if _.isString( res )
      notification "error", res
    else if res is true
      c = new C( comp1, comp2, undefined, DefaultCreateOption )
      $canvas( c.id, true ).select()
      return true
    else if res is false
      return false
    else if res.confirm
      modal MC.template.modalCanvasConfirm( res ), true
      $("#canvas-op-confirm").one "click", ()->
        c = new C( comp1, comp2, undefined, DefaultCreateOption )
        if c.id then $canvas( c.id, true ).select()
        null
    false

  $canvas.connection = ( line_uid )->
    if line_uid
      cache = { uid : Design.__instance.component( line_uid ) }
    else
      cache = Design.__instance.__canvasLines

    lineArray = {}
    for uid, line of cache
      l = {
        type   : line.get("lineType")
        target : {}
      }
      l.target[ line.port1Comp().id ] = line.port1("name")
      l.target[ line.port2Comp().id ] = line.port2("name")

      lineArray[ uid ] = l


    if line_uid
      return lineArray.uid
    else
      return lineArray

  # CanvasEvent is used to deal with the event that will trigger by MC.canvas.js
  CanvasEvent = {
    CANVAS_NODE_SELECTED : ()->
      ide_event.trigger ide_event.OPEN_PROPERTY
      null

    SHOW_PROPERTY_PANEL : ()->
      ide_event.trigger ide_event.FORCE_OPEN_PROPERTY
      null

    CANVAS_PLACE_OVERLAP : () ->
      notification 'warning', lang.ide.CVS_MSG_WARN_COMPONENT_OVERLAP, false
      null

    CANVAS_ZOOMED_DROP_ERROR : ()->
      notification 'warning', lang.ide.CVS_MSG_ERR_ZOOMED_DROP_ERROR
      null

    CANVAS_SAVE : ()->
      ide_event.trigger ide_event.CANVAS_SAVE
      null

    CANVAS_PLACE_NOT_MATCH : ( param )->
      res_type = constant.AWS_RESOURCE_TYPE
      l = lang.ide

      switch param.type
        when res_type.AWS_EBS_Volume  then info = l.CVS_MSG_WARN_NOTMATCH_VOLUME
        when res_type.AWS_VPC_Subnet  then info = l.CVS_MSG_WARN_NOTMATCH_SUBNET

        when res_type.AWS_EC2_Instance
          if Design.instance().typeIsVpc()
            info = l.CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET
          else
            info = l.CVS_MSG_WARN_NOTMATCH_INSTANCE_AZ

        when res_type.AWS_VPC_NetworkInterface  then info = l.CVS_MSG_WARN_NOTMATCH_ENI
        when res_type.AWS_VPC_RouteTable        then info = l.CVS_MSG_WARN_NOTMATCH_RTB
        when res_type.AWS_ELB                   then info = l.CVS_MSG_WARN_NOTMATCH_ELB
        when res_type.AWS_VPC_CustomerGateway   then info = l.CVS_MSG_WARN_NOTMATCH_CGW
        when res_type.AWS_AutoScaling_Group     then info = "Asg must be dragged to a subnet."

      if info
        notification 'warning', info , false
      null
  }

  window.$canvas = $canvas



  ### Canvas is used by $canvas to store data of svg canvas ###
  Canvas = ( size )->
    this.sizeAry      = size || [240, 240]
    this.offsetAry    = [0, 0]
    this.scaleAry     = 1
    this.lineStyle    = 2  # 0:straight  1:elbow line(fold)  2:bezier q,  3:bezier qt
    this.selectedNode = []
    this

  Canvas.prototype.scale = ( ratio )->
    if ratio is undefined
      return this.scaleAry

    this.scaleAry = ratio
    null

  Canvas.prototype.offset = ( x, y )->
    if x is undefined
      return this.offsetAry

    this.offsetAry[0] = x
    this.offsetAry[1] = y
    null

  Canvas.prototype.size = ( w, h )->
    if w is undefined
      return this.sizeAry

    this.sizeAry[0] = w
    this.sizeAry[1] = h
    null

  Canvas.setDesign = ( design )->
    Design = design
    CanvasElement.setDesign( design )

    # Wire Design Event here

    Design.on Design.EVENT.RemoveResource, ( resource )->
      # If removing a selected item, show stack property panel.
      selected = $canvas.selected_node()[0]
      if selected and selected.id is resource.id
        ide_event.trigger ide_event.FORCE_OPEN_PROPERTY
        null
    null

  Canvas

