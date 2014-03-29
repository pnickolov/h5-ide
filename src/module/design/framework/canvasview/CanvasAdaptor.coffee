define [ "./CanvasElement", "event", 'i18n!nls/lang.js', "constant" ], ( CanvasElement, ide_event, lang, constant )->

  Design = null

  ### $canvas is a adaptor for MC.canvas.js ###
  $canvas = ( id, defaultType )->
    component = Design.__instance.component(id)
    if component
      view = component.getCanvasView()

    if not view
      console.debug "Creating an view for an unfound component : ", defaultType, id
      type = if component then component.type else defaultType
      view = CanvasElement.createView( type, component or id )

    view

  $canvas.platform = ()-> Design.instance().type()

  $canvas.size = ( w, h )->
    if Design.__instance
      return Design.__instance.canvas.size( w, h )
    else
      return [240, 240]

  $canvas.scale         = ( ratio )-> Design.__instance.canvas.scale( ratio )
  $canvas.offset        = ()-> $(document.getElementById("svg_canvas")).offset()
  $canvas.selected_node = ()->
    if Design.__instance
      return Design.__instance.canvas.selectedNode
    else
      return null

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
        nodes.push( comp.getCanvasView() )
    nodes

  $canvas.group  = ()->
    _.map Design.__instance.__canvasGroups, ( comp )-> comp.getCanvasView()

  $canvas.clearSelected = ()->
    MC.canvas.event.clearSelected()
    ide_event.trigger ide_event.OPEN_PROPERTY
    null

  $canvas.trigger = ( event )->
    console.assert( _.isString( event ), "Invalid parameter : event " )

    if CanvasEvent[event]
      CanvasEvent[event].apply( this, Array.prototype.slice.call(arguments, 1) )
    null

  $canvas.add = ( type, attributes, pos, createOption )->

    attributes = $.extend { x : pos.x, y : pos.y }, attributes

    parent = attributes.parent
    if not parent
      parent = Design.__instance.component( attributes.groupUId )
      attributes.parent = parent
      delete attributes.groupUId

    if parent
      if parent.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
        attributes.x = parent.x() + 2
        attributes.y = parent.y() + 3
        type = constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      else if parent.type is "ExpandedAsg"
        return false

    Model = Design.modelClassForType type

    createOption = $.extend { createByUser : true }, createOption || {}
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
      if c.id
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

  $canvas.hasVPC = ()->
    !!Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()

  # CanvasEvent is used to deal with the event that will trigger by MC.canvas.js
  CanvasEvent = {
    CANVAS_NODE_SELECTED : ()->
      ide_event.trigger ide_event.OPEN_PROPERTY
      null

    SHOW_STATE_EDITOR : ()->
      ide_event.trigger ide_event.SHOW_STATE_EDITOR
      null

    SHOW_PROPERTY_PANEL : () ->
      ide_event.trigger ide_event.FORCE_OPEN_PROPERTY, 'property'
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

    STATE_ICON_CLICKED : (uid) ->
      ide_event.trigger ide_event.OPEN_STATE_EDITOR, uid
  }

  window.$canvas = $canvas



  ### Canvas is used by $canvas to store data of svg canvas ###
  Canvas = ( size )->
    this.sizeAry      = size || [240, 240]
    this.offsetAry    = [0, 0]
    this.scaleAry     = 1
    this.lineStyle    = 2  # 0:straight  1:elbow line(fold)  2:bezier q,  3:bezier qt
    this.selectedNode = []


    # # #
    # #
    # Quick fix, might improve latter.
    # This is part of the MC.canvas.layout.init()
    # #
    # # #
    attr =
      'width' : this.sizeAry[0] * MC.canvas.GRID_WIDTH
      'height': this.sizeAry[1] * MC.canvas.GRID_HEIGHT

    $('#svg_canvas').attr( attr )
    $('#canvas_container').css( attr )

    this

  Canvas.prototype.scale = ( ratio )->
    if ratio is undefined then return this.scaleAry
    this.scaleAry = ratio
    null

  Canvas.prototype.offset = ( x, y )->
    if x is undefined then return this.offsetAry
    this.offsetAry[0] = x
    this.offsetAry[1] = y
    null

  Canvas.prototype.size = ( w, h )->
    if w is undefined then return this.sizeAry
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
        ide_event.trigger ide_event.FORCE_OPEN_PROPERTY, 'property'
        null
    null

  Canvas

