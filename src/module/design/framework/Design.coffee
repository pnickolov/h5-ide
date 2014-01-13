define [ "constant", "module/design/framework/canvasview/CanvasAdaptor", "CanvasManager" ], ( constant, CanvasAdaptor, CanvasManager ) ->

  ###
    -------------------------------
     Design is the main controller of the framework. It handles the input / ouput of the Application ( a.k.a the DesignCanvas ).
     The input and ouput is the same : the JSON data.
    -------------------------------


    ++ Class Method ++

    # instance() : Design
        description : returns the currently used Design object.

    # modelClassForType( typeString ) : Class
        description : returns an Class for the specified typeString.

    # debug() :
        description : prints all the resource in the console.

    # debug.selectedComp() :
        description : prints the selected resouorce in console.


    ++ Object Method ++

    # component( uid ) : ResourceModel
        description : returns a resource model of uid

    # eachComponent( iterator ) :
        description : the iterator will execute with all the components.

    # use() :
        description : make the design object to be Design.instance()

    # save( component_data, layout_data ) :
        description : save the data, so that isModified() will use the saved data.

    # isModified() : Boolean
        description : returns true if the stack is modified since last save.

    # serialize() : Object
        description : returns a Plain JS Object that is indentical to JSON data.

    # getCost() : Array
        description : return an array of cost object to represent the cost of the stack.



  ###

  Design = ( canvas_data, options )->

    json_data   = canvas_data.component
    layout_data = canvas_data.layout

    # Delete these two attributes before copying canvas_data.
    delete canvas_data.component
    delete canvas_data.layout

    design = (new DesignImpl( $.extend( true, {}, canvas_data ), options )).use()
    design.canvas = new CanvasAdaptor( layout_data.size )

    canvas_data.component = json_data
    canvas_data.layout    = layout_data

    if layout_data.component
      layout_data = $.extend {}, layout_data.component.node, layout_data.component.group

    ###########################
    # Deserialize
    ###########################
    design.deserialize( json_data, layout_data )

    if options.autoFinish isnt false
      design.finishDeserialization()

    design


  _.extend( Design, Backbone.Events )
  Design.__modelClassMap       = {}
  Design.__resolveFirstMap     = {}
  Design.__serializeVisitors   = []
  Design.__deserializeVisitors = []
  Design.__instance            = null


  DesignImpl = ( canvas_data, options )->
    @__componentMap = {}
    @__canvasNodes  = {}
    @__canvasLines  = {}
    @__canvasGroups = {}
    @__classCache   = {}
    @__backup       = {}

    @__mode = options.mode

    # Merge canvas_data
    @attributes = canvas_data

    # Disable drawing for deserializing, delay it until everything is deserialized
    @__shoulddraw   = false
    null


  noop = ()->


  Design.TYPE = {
    Classic    : "ec2-classic"
    Vpc        : "ec2-vpc"
    DefaultVpc : "default-vpc"
    CustomVpc  : "custom-vpc"
  }
  Design.MODE = {
    Stack   : "stack"
    App     : "app"
    AppEdit : "appedit"
    AppView : "appview"
  }

  Design.EVENT = {
    # Events that will trigger using Design.trigger
    AddResource    : "ADD_RESOURCE"
    RemoveResource : "REMOVE_RESOURCE"
    Deserialized   : "DESERIALIZED"

    # Events that will trigger using Design.instance().trigger
    AwsResourceUpdated : "AWS_RESOURCE_UPDATED"
  }


  DesignImpl.prototype.deserialize = ( json_data, layout_data )->

    # Let visitor to fix JSON before it get deserialized.
    for devistor in Design.__deserializeVisitors
      devistor( json_data, layout_data )

    that = @

    # Disable triggering event when Design is deserializing
    Design.trigger = noop


    # A helper function to let each resource to get its dependency
    resolveDeserialize = ( uid )->

      if not uid then return null

      obj = that.__componentMap[ uid ]
      if obj then return obj

      # Check if we have recursive dependency
      console.assert (not recursiveCheck[uid] && recursiveCheck[uid] = true ), "Recursive dependency found when deserializing JSON_DATA"


      component_data = json_data[ uid ]

      ModelClass = Design.modelClassForType( component_data.type )
      if not ModelClass
        console.warn "We do not support deserializing resource of type : #{component_data.type}"
        return

      ModelClass.deserialize( component_data, layout_data[uid], resolveDeserialize )

      Design.__instance.__componentMap[ uid ]

    # Use resolve to replace component(), so that during deserialization,
    # dependency can be resolved by using design.component()
    _old_get_component_ = @component

    ###########################
    # Start deserialization
    # Deserialization cases :
    # subnets need mainRTB and defaultACL, mainRTB needs VPC.
    # Thus, there're 3 steps in the deserialization
    ###########################
    # Deserialize resolveFisrt resources
    @component = null # Forbid user to call component at this time.
    for uid, comp of json_data
      if Design.__resolveFirstMap[ comp.type ] is true
        ModelClass = Design.modelClassForType( comp.type )

        ### env:dev ###
        if not ModelClass
          console.warn "We do not support deserializing resource of type : #{component_data.type}"
          continue
        if not ModelClass.preDeserialize
          console.error "The class is marked as resolveFirst, yet it doesn't implement preDeserialize()"
          continue
        ### env:dev:end ###

        ModelClass.preDeserialize( comp, layout_data[uid] )


    # Deserialize normal resources
    @component = resolveDeserialize
    for uid, comp of json_data

      # If the resource is resolveFirst, it means it will create a resource component
      # in the preDeserialize, meaning that its deserialize will not be called. Thus
      # we directly call the deserialize() of the resource here.
      if Design.__resolveFirstMap[ comp.type ] is true
        recursiveCheck = { uid : true }
        Design.modelClassForType( comp.type ).deserialize( comp, layout_data[uid], resolveDeserialize )
      else
        recursiveCheck = {}
        resolveDeserialize uid


    # Give a chance for resources to create connection between each others.
    @component = _old_get_component_
    for uid, comp of json_data
      ModelClass = Design.modelClassForType( comp.type )
      if ModelClass and ModelClass.postDeserialize
        ModelClass.postDeserialize( comp, layout_data[uid] )
    null

  DesignImpl.prototype.finishDeserialization = ()->
    ####################
    # Draw after deserialization
    ####################
    # Draw everything after deserialization is done.
    # Because some resources might just deleted right after it's been created.
    # And draw lines at the end
    @__shoulddraw = true
    lines = []
    for uid, comp of @__componentMap
      if not comp.draw then continue
      if comp.node_line
        lines.push comp
      else
        comp.draw( true )

    for comp in lines
      comp.draw( true )

    ####################
    # Broadcast event
    ####################
    # Restore Design.trigger
    Design.trigger = Backbone.Events.trigger
    Design.trigger Design.EVENT.Deserialized

    @save()
    null

  ### Private Interface ###
  Design.registerModelClass = ( type, modelClass, resolveFirst )->
    @__modelClassMap[ type ] = modelClass
    if resolveFirst
      @__resolveFirstMap[ type ] = resolveFirst
    null

  DesignImpl.prototype.classCacheForCid = ( cid )->
    if @__classCache[ cid ]
      return @__classCache[ cid ]

    cache = @__classCache[ cid ] = []
    return cache

  DesignImpl.prototype.cacheComponent = ( id, comp )->
    if not comp
      comp = @__componentMap
      delete @__componentMap[ id ]
      delete @__canvasGroups[ id ]
      delete @__canvasNodes[ id ]
    else
      @__componentMap[ id ] = comp

      # Cache them into another cache if they are visual objects
      if _.isFunction comp.draw
        if comp.node_group
          @__canvasGroups[ id ] = comp
        else if comp.node_line
          @__canvasLines[ id ] = comp
        else
          @__canvasNodes[ id ] = comp
    null


  Design.registerSerializeVisitor = ( func )->
    @__serializeVisitors.push func
    null

  Design.registerDeserializeVisitor = ( func )->
    @__deserializeVisitors.push func
    null

  ### env:dev ###
  Design.debug = ()->
    componentMap = Design.instance().__componentMap
    canvasNodes  = Design.instance().__canvasNodes
    canvasGroups = Design.instance().__canvasGroups
    checkedMap   = {
      "line"            : {}
      "node"            : {}
      "group"           : {}
      "otherResource"   : {}
      "otherConnection" : {}
    }
    checked = {}
    for id, a of canvasNodes
      checked[ id ] = true
      checkedMap.node[ a.id ] = a
    for id, a of canvasGroups
      checked[ id ] = true
      checkedMap.group[ a.id] = a
    for id, a of componentMap
      if checked[ id ] then continue
      if a.node_line
        if a.draw
          checkedMap.line[ a.id ] = a
        else
          checkedMap.otherConnection[ a.id ] = a
      else
        checkedMap.otherResource[ a.id ] = a

    checkedMap

  Design.debug.selectedComp = ()->
    Design.instance().component( $("#svg_canvas").find(".selected").attr("id") )

  window.ds = ()->
    console.log( Design.instance().serialize() )
    null
  ### env:dev:end ###

  ### Private Interface End ###



  Design.instance = ()-> @__instance
  Design.modelClassForType = ( type )-> @__modelClassMap[ type ]
  Design.modelClassForPorts = ( port1, port2 )->
    if port1 < port2
      type = port1 + ">" + port2
    else
      type = port2 + ">" + port1

    @__modelClassMap[ type ]

  DesignImpl.prototype.get = ( key )-> @attributes[key]
  DesignImpl.prototype.set = ( key, value )->
    @attributes[key] = value
    null

  DesignImpl.prototype.region = ()-> @.attributes.region
  DesignImpl.prototype.mode   = ()->
    console.warn("Better not to use Design.instance().mode() directly.")
    @__mode

  DesignImpl.prototype.modeIsStack   = ()-> @__mode == Design.MODE.Stack
  DesignImpl.prototype.modeIsApp     = ()-> @__mode == Design.MODE.App
  DesignImpl.prototype.modeIsAppEdit = ()-> @__mode == Design.MODE.AppEdit
  DesignImpl.prototype.setMode = (m)->
    @__mode = m
    null

  DesignImpl.prototype.type             = ()-> @attributes.platform
  DesignImpl.prototype.typeIsClassic    = ()-> @attributes.platform == Design.TYPE.Classic
  DesignImpl.prototype.typeIsDefaultVpc = ()-> @attributes.platform == Design.TYPE.DefaultVpc
  DesignImpl.prototype.typeIsVpc        = ()-> @attributes.platform == Design.TYPE.Vpc or @attributes.platform is Design.TYPE.CustomVpc

  DesignImpl.prototype.shouldDraw = ()-> @__shoulddraw
  DesignImpl.prototype.use = ()->
    Design.__instance = @
    @

  DesignImpl.prototype.component = ( uid )-> @__componentMap[ uid ]

  DesignImpl.prototype.eachComponent = ( func, context )->
    console.assert( _.isFunction(func), "User must pass in a function for Design.instance().eachCOmponent()" )

    context = context || this
    for uid, comp of @__componentMap
      func.call( context, comp )
    null

  DesignImpl.prototype.save = ( component_data, layout_data )->
    @__backup.name = @attributes.name

    # Quick Impl to make process work.
    if component_data and layout_data
      @__backup.component = component_data
      @__backup.layout    = layout_data
    else
      newData = @serialize()
      @__backup.component = newData.component
      @__backup.layout    = newData.layout
    null

  DesignImpl.prototype.isModified = ()->
    if @__backup.name isnt @attributes.name
      return false

    newData = @serialize()

    if _.isEqual( @__backup.component, newData.component )
      if _.isEqual( @__backup.layout, newData.layout )
        return false

    true

  DesignImpl.prototype.serialize = ()->

    console.debug "Design is serializing."

    component_data = {}
    layout_data    = {}

    connections = []
    mockArray   = []

    # ResourceModel can only add json component.
    for uid, comp of @__componentMap
      if comp.isRemoved()
        console.warn( "Resource has been removed, yet it remains in cache when serializing :", comp )
        continue

      if comp.node_line
        connections.push comp
        continue

      json = comp.serialize()
      if not json then continue

      # Make json to be an array
      if not _.isArray( json )
        mockArray[0] = json
        json = mockArray

      for j in json
        if j.component
          console.assert( j.component.uid, "Serialized JSON data has no uid." )
          console.assert( not component_data[ j.component.uid ], "ResourceModel cannot modify existing JSON data." )
          component_data[ j.component.uid ] = j.component

        if j.layout
          layout_data[ j.layout.uid ] = j.layout

    # Connection
    for c in connections
      c.serialize( component_data, layout_data )


    # At this point, we allow each ModelClass to have full privilege to modify
    # the component data. This is necessary for ModelClass that wants to work on
    # many components at once. ( One use-case is Subnet would like to assign IPs. )
    for visitor in Design.__serializeVisitors
      visitor( component_data, layout_data )


    # Seems like some other place have call Design.instance().set("layout")
    # So we assign component/layout at last
    data = $.extend( { property : {} }, @attributes )
    data.component = component_data
    data.layout    = layout_data

    # Quick Fix for some other property
    # 1. save $canvas's size to layout
    data.layout.size = @canvas.sizeAry
    # 2. save stoppable to property
    data.property.stoppable = @isStoppable()

    data


  ########## General Business logics ############
  DesignImpl.prototype.getCost = ()->
    costList = []
    totalFee = 0

    feeMap = MC.data.config[ @region() ]

    if feeMap and feeMap.price
      priceMap = feeMap.price
      currency = feeMap.price.currency || 'USD'

      for uid, comp of @__componentMap
        if comp.getCost
          cost = comp.getCost( priceMap, currency )
          if not cost then continue

          if cost.length
            for c in cost
              totalFee += c.fee
              costList.push c
          else
            totalFee += cost.fee
            costList.push cost

      costList = _.sortBy costList, "resource"

    { costList : costList, totalFee : Math.round(totalFee * 100) / 100 }

  ########## AWS Business logics ############
  DesignImpl.prototype.isStoppable = ()->
    # Previous version will set canvas_data.property.stoppable to false
    # If the stack contains instance-stor ami.
    InstanceModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance )
    LcModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration )
    allObjects = InstanceModel.allObjects().concat LcModel.allObjects()
    for comp in allObjects
      ami = comp.getAmi() or comp.get("cachedAmi")
      if ami and ami.rootDeviceType is 'instance-store'
        return false
    true

  DesignImpl.prototype.clearResourceInCache = ()->
    # module/design/model would like to clear all the data in the data.resource_list
    resource_list = MC.data.resource_list[ @region() ]
    if not resource_list then return

    @eachComponent ()->
      appId = @get("appId")
      delete resource_list[ resource_list ]
    console.debug "data.resource_list has been cleared", resource_list
    null

  _.extend DesignImpl.prototype, Backbone.Events
  DesignImpl.prototype.on = ( event )->
    # Do nothing for AwsResourceUpdated if it's in stack mode.
    if event is Design.EVENT.AwsResourceUpdated and @modeIsStack()
      return

    Backbone.Events.on.apply( this, arguments )


  # Inject dependency, so that CanvasManager/CanvasAdaptor won't require Design.js
  CanvasManager.setDesign( Design )
  CanvasAdaptor.setDesign( Design )


  Design
