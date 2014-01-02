define [ "constant", "module/design/framework/canvasview/CanvasAdaptor", "CanvasManager" ], ( constant, CanvasAdaptor, CanvasManager ) ->

  ###
    -------------------------------
     Design is the main controller of the framework. It handles the input / ouput of the Application ( a.k.a the DesignCanvas ).
     The input and ouput is the same : the JSON data.
    -------------------------------


    ++ Class Method ++

    # instance() : Design
        description : returns the currently used Design object.


    ++ Object Method ++

    # component( uid ) : ResourceModel
        description : returns a resource model of uid

    # serialize() : Object
        description : returns a Plain JS Object that is indentical to JSON data.

    # serializeLayout() : Object
        description : returns a Plain JS Object that is indentical to Layout data.

  ###

  Design = ( json_data, layout_data, options )->

    design = (new DesignImpl( options )).use()
    design.canvas = new CanvasAdaptor( layout_data.size )

    json_data   = $.extend true, {}, json_data
    if layout_data.component
      layout_data = $.extend true, {}, layout_data.component.node, layout_data.component.group
    else
      layout_data = {}

    ###########################
    # Quick fix Boolean value in JSON, might removed latter
    ###########################
    Design.fixJson( json_data, layout_data )

    design.deserialize( json_data, layout_data )
    design


  _.extend( Design, Backbone.Events )
  Design.__modelClassMap   = {}
  Design.__resolveFirstMap = {}
  Design.__instance        = null

  # Inject dependency, so that CanvasManager/CanvasAdaptor won't require Design.js
  CanvasManager.setDesign( Design )
  CanvasAdaptor.setDesign( Design )


  DesignImpl = ( options )->
    @__componentMap = {}
    @__canvasNodes  = {}
    @__canvasLines  = {}
    @__canvasGroups = {}
    @__classCache   = {}

    @__type   = options.type
    @__mode   = options.mode
    @__region = options.region

    # TODO : QuickFix
    for key, value of MC.canvas_data
      if key is "component" or key is "layout" then continue
      @["__" + key] = value

    # Disable drawing for deserializing, delay it until everything is deserialized
    @__shoulddraw   = false
    null


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
    AddResource    : "ADD_RESOURCE"
    RemoveResource : "REMOVE_RESOURCE"

    Deserialized : "DESERIALIZED"
  }


  DesignImpl.prototype.deserialize = ( json_data, layout_data )->

    that = @

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
    Design.trigger Design.EVENT.Deserialized
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
      Design.trigger Design.EVENT.AddResource, comp
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

      Design.trigger Design.EVENT.RemoveResource, comp
    null


  Design.fixJson = ( data, layout_data )->

    azMap = {}
    azArr = []

    for uid, comp of layout_data

      # Generate Component for AZ
      if comp.type is "AWS.EC2.AvailabilityZone"
        azArr.push {
          uid  : uid
          type : "AWS.EC2.AvailabilityZone"
          name : comp.name
        }

        azMap[ comp.name ] = "@#{uid}.name"

      # Generate Component for expanded Asg
      else if comp.type is "AWS.AutoScaling.Group"
        if comp.originalId
          data[ uid ] = {
            type : "ExpandedAsg"
            uid  : uid
          }

    # Fix AZ reference and Change Boolean value
    checkObj = ( obj )->
      for attr, d of obj
        if _.isString( d )
          if d is "true"
            obj[ attr ] = true
          else if d is "false"
            obj[ attr ] = false

          else if azMap[ d ] # Change azName to id
            obj[ attr ] = azMap[ d]

        else if _.isArray( d )
          for dd, idx in d
            if _.isObject( dd )
              checkObj( dd )
            if _.isString( dd )
              if d is "true"
                d[ idx ] = true
              else if d is "false"
                d[ idx ] = false

              else if azMap[ d ] # Change azName to id
                d[ idx ] = azMap[ d]

        else if _.isObject( d )
          checkObj( d )
      null

    for uid, comp of data
      checkObj( comp )

    for az in azArr
      data[ az.uid ] = az
    null

  ### env:dev ###
  Design.debug = ()->
    transform = ( a )->
      b = {}
      ignore = "|idAttribute|_pending|_changing|_previousAttributes|__design|validationError|node_group|node_line|changed|defaults|id|newNameTmpl"
      for att of a
        if _.isFunction( a[att] ) then continue
        if ignore.indexOf( "|" + att + "|" ) isnt -1 then continue

        if _.isArray( a[att] ) and a[att].length
          if a[att][0].isTypeof
            b[att] = []
            for x in a[att]
              b[att].push x.id
          else
            b[att] = $.extend( true, [], a[att] )
        else if _.isObject( a[att] ) and not _.isEmpty( a[att] )
          b[att] = $.extend( true, {}, a[att] )
        else
          b[att] = a[att]
      if b.attibutes and b.attributes.name then b.name = b.attibutes.name

      map = {}
      funcName = b.type.replace(/\./g, "_")
      ### jshint -W061 ###
      obj = eval( "(function #{funcName}( a ){ $.extend( true, this, a ); })" )
      ### jshint +W061 ###
      new obj( b )

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
      checkedMap.node[ a.id ] = transform( a )
    for id, a of canvasGroups
      checked[ id ] = true
      checkedMap.group[ a.id] = transform( a )
    for id, a of componentMap
      if checked[ id ] then continue
      if a.node_line
        if a.draw
          checkedMap.line[ a.id ] = transform( a )
        else
          checkedMap.otherConnection[ a.id ] = transform( a )
      else
        checkedMap.otherResource[ a.id ] = transform( a )

    checkedMap
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

  DesignImpl.prototype.get = ( key )-> @["__"+key]

  DesignImpl.prototype.region = ()-> @.__region
  DesignImpl.prototype.mode   = ()->
    console.warn("Better not to use Design.instance().mode() directly.")
    this.__mode

  DesignImpl.prototype.type   = ()->
    console.warn("Better not to use Design.instance().type() directly.")
    this.__type


  DesignImpl.prototype.modeIsStack   = ()-> this.__mode == Design.MODE.Stack
  DesignImpl.prototype.modeIsApp     = ()-> this.__mode == Design.MODE.App
  DesignImpl.prototype.modeIsAppEdit = ()-> this.__mode == Design.MODE.AppEdit
  DesignImpl.prototype.setMode = (m)->
    this.__mode = m
    null

  DesignImpl.prototype.typeIsClassic    = ()-> this.__type == Design.TYPE.Classic
  DesignImpl.prototype.typeIsDefaultVpc = ()-> this.__type == Design.TYPE.DefaultVpc
  DesignImpl.prototype.typeIsVpc        = ()-> this.__type == Design.TYPE.Vpc or this.__type is Design.TYPE.CustomVpc

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

  DesignImpl.prototype.getCost = ()->
    costList = []
    totalFee = 0

    feeMap = MC.data.config[ @__region ]

    if feeMap and feeMap.price
      priceMap = feeMap.price
      currency = feeMap.price.currency || 'USD'

      for uid, comp of @__componentMap
        if comp.getCost
          cost = comp.getCost( priceMap, currency )
          if cost
            totalFee += cost.fee
            costList.push cost

      costList = _.sortBy costList, "resource"

    { costList : costList, totalFee : Math.round(totalFee * 100) / 100 }

  DesignImpl.prototype.serialize = ()->

    json_data   = {}

    connections = []
    mockArray   = []

    # ResourceModel can only add json component.
    for uid, comp of @__componentMap
      if comp.node_line
        connections.push comp
        continue

      json = comp.serialize()
      if not json
        continue

      # Make json to be an array
      if not _.isArray( json )
        mockArray[0] = json
        json = mockArray

      for j in json
        console.assert( j.uid, "Serialized JSON data has no uid." )
        console.assert( not json_data[ j.uid ], "ResourceModel cannot modify existing JSON data." )
        json_data[ j.uid ] = j

    # Connection
    for c in connections
      c.serialize( json_data )

    json_data


  DesignImpl.prototype.serializeLayout = ()->

  Design
