define [
  "constant"
  "OpsModel"
  'CloudResources'
], ( constant, OpsModel, CloudResources ) ->

  # The recursiveCheck is not fully working.
  ### env:prod ###
  createRecursiveCheck = ()->
    return createRecursiveCheck.o or (createRecursiveCheck.o = {
      check : ()->
    })
  ### env:prod:end ###
  ### env:dev ###
  createRecursiveCheck = ( uid )->
    robj = {}
    robj.cache = []
    robj.check = ( uid )->
      idx = robj.cache.indexOf( uid )
      if idx is 0 or (idx > 0 and idx isnt robj.cache.length - 1)
        console.error "Possible Recursive dependency found when deserializing JSON_DATA, uid: " + uid
        return
      robj.cache.push uid
      null

    if uid then robj.check( uid )
    robj
  ### env:dev:end ###

  noop = ()-> return

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

    # serializeAsStack() : Object
        description : same as serialize(), but it ensure that the JSON will be a stack JSON.

    # getCost() : Array
        description : return an array of cost object to represent the cost of the stack.



  ###

  Design = ( opsModel )->
    design = (new DesignImpl( opsModel )).use()
    # Deserialize
    json = opsModel.getJsonData()
    design.deserialize( $.extend(true, {}, json.component), $.extend(true, {}, json.layout) )
    design

  _.extend( Design, Backbone.Events )
  Design.__modelClassMap       = {}
  Design.__resolveFirstMap     = {}
  Design.__serializeVisitors   = []
  Design.__deserializeVisitors = []
  Design.__instance            = null


  DesignImpl = ( opsModel )->
    @__componentMap = {}
    @__classCache   = {}
    @__usedUidCache = {}
    @__opsModel     = opsModel
    @__initializing = false # Disable drawing for deserializing, delay it until everything is deserialized

    canvas_data = opsModel.getJsonData()

    # Mode
    if opsModel.testState( OpsModel.State.UnRun )
      @__mode = Design.MODE.Stack
    else
      @__mode = Design.MODE.App

    # Delete these two attr before copying canvas_data.
    component = canvas_data.component
    layout    = canvas_data.layout
    delete canvas_data.component
    delete canvas_data.layout

    @attributes = $.extend true, { canvasSize : layout.size }, canvas_data

    # Restore these two attr
    canvas_data.component = component
    canvas_data.layout    = layout
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
  }

  Design.EVENT = {
    # Events that will trigger using Design.trigger

    # Events that will trigger using Design.instance().trigger
    ChangeResource : "CHANGE_RESOURCE"

    # Events that will trigger both using Design.trigger and Design.instance().trigger
    AddResource    : "ADD_RESOURCE"
    RemoveResource : "REMOVE_RESOURCE"
    Deserialized   : "DESERIALIZED"
  }

  DesignImpl.prototype.refreshAppUpdate = () ->
    needRefresh = [
      constant.RESTYPE.ASG
    ]

    @eachComponent ( component ) ->
      if component.type in needRefresh
        component.draw()

    null

  DesignImpl.prototype.deserialize = ( json_data, layout_data )->

    console.debug "Deserializing data :", [json_data, layout_data]

    # Let visitor to fix JSON before it get deserialized.
    version = @get("version")
    for devistor in Design.__deserializeVisitors
      devistor( json_data, layout_data, version )

    # Disable triggering event when Design is deserializing
    @trigger = Design.trigger = noop
    @__initializing = true


    # A helper function to let each resource to get its dependency
    that = this
    resolveDeserialize = ( uid )->

      if not uid then return null

      obj = that.__componentMap[ uid ]
      if obj then return obj

      # Check if we have recursive dependency
      recursiveCheck.check( uid )

      component_data = json_data[ uid ]

      if not component_data
        console.warn "Unknown uid for resolving component :", uid, json_data
        return

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

      # Collect Used UID. So that we can ensure we will always generate unique uid.
      @__usedUidCache[ uid ] = true

      if Design.__resolveFirstMap[ comp.type ] is true
        ModelClass = Design.modelClassForType( comp.type )

        if not ModelClass
          console.warn "We do not support deserializing resource of type : #{component_data.type}"
          continue
        if not ModelClass.preDeserialize
          console.error "The class is marked as resolveFirst, yet it doesn't implement preDeserialize()"
          continue

        ModelClass.preDeserialize( comp, layout_data[uid] )


    # Deserialize normal resources
    @component = resolveDeserialize
    for uid, comp of json_data

      # If the resource is resolveFirst, it means it will create a resource component
      # in the preDeserialize, meaning that its deserialize will not be called. Thus
      # we directly call the deserialize() of the resource here.
      if Design.__resolveFirstMap[ comp.type ] is true
        recursiveCheck = createRecursiveCheck( uid )
        Design.modelClassForType( comp.type ).deserialize( comp, layout_data[uid], resolveDeserialize )
      else
        recursiveCheck = createRecursiveCheck()
        resolveDeserialize uid


    # Give a chance for resources to create connection between each others.
    @component = _old_get_component_
    for uid, comp of json_data
      ModelClass = Design.modelClassForType( comp.type )
      if ModelClass and ModelClass.postDeserialize
        ModelClass.postDeserialize( comp, layout_data[uid] )

    ####################
    # Broadcast event
    ####################
    @__initializing = false
    @trigger = Design.trigger = Backbone.Events.trigger
    Design.trigger Design.EVENT.Deserialized
    @trigger Design.EVENT.Deserialized
    null

  DesignImpl.prototype.reload = ()->
    DesignImpl.call this, @__opsModel
    json = @__opsModel.getJsonData()
    @deserialize( $.extend(true, {}, json.component), $.extend(true, {}, json.layout) )

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

      # Only in stack mode, we reclaim the id once the component is removed from cache.
      if @modeIsAppEdit()
        @reclaimGuid( id )
    else
      @__componentMap[ id ] = comp
    null


  Design.registerSerializeVisitor = ( func )->
    @__serializeVisitors.push func
    null

  Design.registerDeserializeVisitor = ( func )->
    @__deserializeVisitors.push func
    null

  ### Private Interface End ###



  Design.instance = ()-> @__instance
  Design.modelClassForType = ( type )-> @__modelClassMap[ type ]
  Design.modelClassForPorts = ( port1, port2 )->
    if port1 < port2
      type = port1 + ">" + port2
    else
      type = port2 + ">" + port1

    @__modelClassMap[ type ]

  Design.lineModelClasses = ()->
    if @__lineModelClasses then return @__lineModelClasses

    @__lineModelClasses = cs = []
    for type, modelClass of @__modelClassMap
      # Ignore every type that has ">", because that's duplicated class for a line.
      if modelClass.__isLineClass and type.indexOf(">") is -1
        cs.push modelClass

    @__lineModelClasses

  DesignImpl.prototype.reclaimGuid = ( guid )-> delete @__usedUidCache[ guid ]
  DesignImpl.prototype.guid = ()->
    newId = MC.guid()
    while @__usedUidCache[ newId ]
      console.warn "GUID collision detected, the generated GUID is #{newId}. Try generating a new one."
      newId = MC.guid()

    @__usedUidCache[ newId ] = true
    newId

  DesignImpl.prototype.set = ( key, value )->
    @attributes[key] = value
    @trigger "change:#{key}"
    @trigger "change"
    return

  DesignImpl.prototype.get = ( key )->
    if key is "id"
      @__opsModel.get( "id" )
    else if key is "state"
      @__opsModel.getStateDesc()
    else
      @attributes[key]

  DesignImpl.prototype.type   = ()-> Design.TYPE.Vpc
  DesignImpl.prototype.region = ()-> @attributes.region

  DesignImpl.prototype.modeIsStack   = ()->  @__mode == Design.MODE.Stack
  DesignImpl.prototype.modeIsApp     = ()->  @__mode == Design.MODE.App
  DesignImpl.prototype.modeIsAppView = ()->  false
  DesignImpl.prototype.modeIsAppEdit = ()->  @__mode == Design.MODE.AppEdit
  DesignImpl.prototype.mode    = ()-> @__mode
  DesignImpl.prototype.setMode = (m)->
    if @__mode is m then return
    @__mode = m
    @trigger "change:mode", m
    return



  DesignImpl.prototype.initializing = ()-> @__initializing
  DesignImpl.prototype.use = ()-> Design.__instance = @; @
  DesignImpl.prototype.unuse = ()-> if Design.__instance is @ then Design.__instance = null; return

  DesignImpl.prototype.component = ( uid )-> @__componentMap[ uid ]

  DesignImpl.prototype.componentsOfType = ( type )->
    @classCacheForCid( Design.modelClassForType(type).prototype.classId ).slice(0)

  DesignImpl.prototype.eachComponent = ( func, context )->
    console.assert( _.isFunction(func), "User must pass in a function for Design.instance().eachComponent()" )

    context = context || this
    for uid, comp of @__componentMap
      if func.call( context, comp ) is false
        break
    null

  DesignImpl.prototype.isModified = ()->
    # This api only compares name / component / layout
    if @modeIsApp()
      console.warn "Testing Design.isModified() in app mode and visualize mode. This should not be happening."
      return false

    backing = @__opsModel.getJsonData()

    # Shallow Compare.
    if @attributes.name isnt backing.name then return true

    newData = @serialize()

    if _.isEqual( backing.component, newData.component )
      if _.isEqual( backing.layout, newData.layout )
        return false
    true

  DesignImpl.prototype.serialize = ( options )->

    # A hack to get around the caveat of the current framework design.
    # The Design is singleton (Because the Design is created with the mind
    # that trying to affect as little as possible of the current system)
    # Which makes it unusable in work with multiple design objects in the same time.
    # It seems like if we do want to support this feature, we need to introduce
    # inconvenient api, which I don't want to.
    currentDesignObj = Design.instance()
    @use()

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

      try
        json = comp.serialize options
        ### env:prod ###
      catch error
        console.error "Error occur while serializing", error
        ### env:prod:end ###
      finally

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
      p1 = c.port1Comp()
      p2 = c.port2Comp()
      if p1 and p2 and not p1.isRemoved() and not p2.isRemoved()
        try
          c.serialize( component_data, layout_data )
          ### env:prod ###
        catch error
          console.error "Error occur while serializing", error
          ### env:prod:end ###
        finally

      else
        console.error "Serializing an connection while one of the port is isRemoved() or null"


    # Seems like some other place have call Design.instance().set("layout")
    # So we assign component/layout at last
    data = $.extend true, {}, @attributes
    data.component = component_data
    data.layout    = layout_data



    # At this point, we allow each visitors to have full privilege to modify
    # the component data. This is necessary for visitors that wants to work on
    # many components at once. ( One use-case is Subnet would like to assign IPs. )
    for visitor in Design.__serializeVisitors
      visitor( component_data, layout_data, options )


    # Quick Fix for some other property
    # 1. save canvas's size to layout
    data.layout.size = data.canvasSize
    delete data.canvasSize

    # 2. save stoppable to property
    data.property = @attributes.property || {}
    data.property.stoppable = @isStoppable()

    data.version = "2014-02-17"
    data.state   = @__opsModel.getStateDesc() || "Enabled"
    data.id      = @__opsModel.get("id")

    if currentDesignObj
      currentDesignObj.use()

    data


  DesignImpl.prototype.serializeAsStack = (new_name)->
    json = @serialize( { toStack : true } )

    json.name = new_name||json.name
    json.state = "Enabled"
    json.id = ""
    json.owner = ""
    json.usage = ""
    delete json.history
    delete json.stack_id
    json


  DesignImpl.prototype.getUidByProperty = ( property, value, res_type = null )->
    # get uid by property in stack/app json
    # example: getUidByProperty("resource.ImageId","ami-178e927e")
    if not property then return
    json_data = @serialize()
    result = {}
    if json_data and json_data.component
      for uid, comp of json_data.component
        if (res_type is null or comp.type is res_type )
          context = comp
          namespaces = property.split('.')
          last = namespaces.pop()
          for key in namespaces
            context = context[ key ]
          if context[ last ] is value
            if not result[comp.type]
              result[comp.type] = []
            result[comp.type].push uid
    result


  ########## General Business logics ############
  DesignImpl.prototype.getCost = ()->
    costList = []
    totalFee = 0

    priceMap = App.model.getPriceData( @region() )

    if priceMap
      currency = priceMap.currency || 'USD'

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

  DesignImpl.prototype.isStoppable = ()->
    # Previous version will set canvas_data.property.stoppable to false
    # If the stack contains instance-stor ami.
    InstanceModel = Design.modelClassForType( constant.RESTYPE.INSTANCE )
    LcModel = Design.modelClassForType( constant.RESTYPE.LC )
    allObjects = InstanceModel.allObjects( @ ).concat LcModel.allObjects( @ )
    for comp in allObjects
      ami = comp.getAmi() or comp.get("cachedAmi")
      if ami and ami.rootDeviceType is 'instance-store'
        return false

    vpc = Design.modelClassForType( constant.RESTYPE.VPC ).allObjects( @ )
    if vpc.length>0
      vpcId = vpc[0].get("appId")
      instanceAry = CloudResources( constant.RESTYPE.INSTANCE, @region() ).filter ( model ) =>  model.RES_TAG is vpcId
      for ins in instanceAry
        ins = ins.attributes
        for bdm in (ins.blockDeviceMapping || [])
          if bdm.ebs is null and bdm.VirtualName
            #blockDevice is instance-store
            return false
    true

  DesignImpl::instancesNoUserData = ()->
    result = true
    instanceModels = Design.modelClassForType(constant.RESTYPE.INSTANCE).allObjects()
    _.each instanceModels , (instanceModel)->
      result = if  instanceModel.get('userData') then false else true
      null
    lcModels = Design.modelClassForType( constant.RESTYPE.LC ).allObjects()
    _.each lcModels , (lcModel)->
      result = if lcModel.get('userData') then false else true
      null
    return result

  _.extend DesignImpl.prototype, Backbone.Events

  # Export DesignImpl through Design, so that we can add debug code in DesignDebugger
  ### env:dev ###
  Design.DesignImpl = DesignImpl
  ### env:dev:end ###
  ### env:debug ###
  Design.DesignImpl = DesignImpl
  ### env:debug:end ###

  Design
