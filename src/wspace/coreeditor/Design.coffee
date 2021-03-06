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


  __modelClassMap   = {}
  __resolveFirstMap = {}
  __instance        = null

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

    # isModified() : Boolean
        description : returns true if the stack is modified since last save.

    # serialize() : Object
        description : returns a Plain JS Object that is indentical to JSON data.

    # serializeAsStack() : Object
        description : same as serialize(), but it ensure that the JSON will be a stack JSON.

    # getCost() : Array
        description : return an array of cost object to represent the cost of the stack.

  ###

  # Warning! Although Design extends from Backbone.Model
  # But do not use any Backbone.Model method on Design object.
  Design = Backbone.Model.extend {

    constructor : ( opsModel )->
      @__opsModel = opsModel
      Backbone.Model.call this
      @use()
      return

    initialize : ( )->
      @__componentMap = {}
      @__classCache   = {}
      @__usedUidCache = {}
      @__initializing = false # Disable drawing for deserializing, delay it until everything is deserialized

      canvas_data = @__opsModel.getJsonData()

      # Mode
      if @__opsModel.isStack()
        @__mode = Design.MODE.Stack
      else
        @__mode = Design.MODE.App

      # Delete these two attr before copying canvas_data.
      component = canvas_data.component
      layout    = canvas_data.layout
      delete canvas_data.component
      delete canvas_data.layout

      @attributes = $.extend true, { canvasSize : layout.size }, canvas_data

      # Before we can deserialize, we need to make the design as current design.
      oldDesign = Design.instance()
      @use()
      @deserialize( $.extend(true, {}, component), $.extend(true, {}, layout) )
      if oldDesign then oldDesign.use()
      null

    deserialize : ( json_data, layout_data )->

      console.assert( Design.instance() is this )

      console.debug "Deserializing data :", [json_data, layout_data]

      # Let visitor to fix JSON before it get deserialized.
      version = @get("version")
      for devistor in @constructor.__deserializeVisitors || []
        devistor( json_data, layout_data, version )

      # Disable triggering event when Design is deserializing
      @trigger = noop
      @__initializing = true

      defaultLayout = {
        coordinate : [0, 0]
        size       : [0, 0]
      }

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

        ModelClass.deserialize( component_data, layout_data[uid] || defaultLayout, resolveDeserialize )

        __instance.__componentMap[ uid ]

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

        if __resolveFirstMap[ comp.type ] is true
          ModelClass = Design.modelClassForType( comp.type )

          if not ModelClass
            console.warn "We do not support deserializing resource of type : #{component_data.type}"
            continue
          if not ModelClass.preDeserialize
            console.error "The class is marked as resolveFirst, yet it doesn't implement preDeserialize()"
            continue

          ModelClass.preDeserialize( comp, layout_data[uid] || defaultLayout )


      # Deserialize normal resources
      @component = resolveDeserialize
      for uid, comp of json_data

        # If the resource is resolveFirst, it means it will create a resource component
        # in the preDeserialize, meaning that its deserialize will not be called. Thus
        # we directly call the deserialize() of the resource here.
        if __resolveFirstMap[ comp.type ] is true
          recursiveCheck = createRecursiveCheck( uid )
          Design.modelClassForType( comp.type ).deserialize( comp, layout_data[uid] || defaultLayout, resolveDeserialize )
        else
          recursiveCheck = createRecursiveCheck()
          resolveDeserialize uid


      # Give a chance for resources to create connection between each others.
      @component = _old_get_component_
      for uid, comp of json_data
        ModelClass = Design.modelClassForType( comp.type )
        if ModelClass and ModelClass.postDeserialize
          ModelClass.postDeserialize( comp, layout_data[uid] || defaultLayout )

      ####################
      # Broadcast event
      ####################
      @__initializing = false
      # Send out two types of event here.
      # The Deserialized event is used by resource model, (e.g. security group) to know when other resource have done
      # deserialaztion. So that they can perform some interaction with other resources.
      Backbone.Events.trigger.call @, Design.EVENT.Deserialized
      Design.trigger Design.EVENT.Deserialized, @

      # After all the resource models are fully deseralized.
      # This event is send out to notify other objects that are not within the design (e.g. some kind of view)
      # that the design has done deserialaztion.
      Backbone.Events.trigger.call @, Design.EVENT.DidDeserialized
      Design.trigger Design.EVENT.DidDeserialized, @


      # Only at this point, we are finally deserialized.
      @trigger = Backbone.Events.trigger
      null

    reload : ()-> @initialize()

    classCacheForCid : ( cid )->
      if @__classCache[ cid ]
        return @__classCache[ cid ]

      cache = @__classCache[ cid ] = []
      return cache

    cacheComponent : ( id, comp )->
      if not comp
        comp = @__componentMap
        delete @__componentMap[ id ]

        # Only in stack mode, we reclaim the id once the component is removed from cache.
        if @modeIsAppEdit()
          @reclaimGuid( id )
      else
        @__componentMap[ id ] = comp
      null

    reclaimGuid : ( guid )-> delete @__usedUidCache[ guid ]
    guid : ()->
      newId = MC.guid()
      while @__usedUidCache[ newId ]
        console.warn "GUID collision detected, the generated GUID is #{newId}. Try generating a new one."
        newId = MC.guid()

      @__usedUidCache[ newId ] = true
      newId

    set : ( key, value )->
      @attributes[key] = value
      @trigger "change:#{key}"
      @trigger "change"
      return

    get : ( key )->
      if key is "id"
        @__opsModel.get( "id" )
      else if key is "state"
        @__opsModel.getStateDesc()
      else
        @attributes[key]

    type   : ()-> @__opsModel.type
    region : ()-> @attributes.region

    project: () -> @__opsModel.project()

    credential   : ()-> @__opsModel.credential()
    credentialId : ()-> @__opsModel.credentialId()

    opsModel : ()-> @__opsModel

    modeIsStack   : ()->  @__mode == Design.MODE.Stack
    modeIsApp     : ()->  @__mode == Design.MODE.App
    modeIsAppView : ()->  false
    modeIsAppEdit : ()->  @__mode == Design.MODE.AppEdit
    mode    : ()-> @__mode
    setMode : (m)->
      if @__mode is m then return
      @__mode = m

      @preserveName()

      @trigger "change:mode", m
      return


    initializing : ()-> @__initializing
    use : ()-> __instance = @; @
    unuse : ()-> if __instance is @ then __instance = null; return

    component : ( uid )->
      if not uid then return null
      @__componentMap[ uid ]

    componentsOfType : ( type )->
      @classCacheForCid( Design.modelClassForType(type).prototype.classId ).slice(0)

    eachComponent : ( func, context )->
      console.assert( _.isFunction(func), "User must pass in a function for Design.instance().eachComponent()" )

      context = context || this
      for uid, comp of @__componentMap
        if func.call( context, comp ) is false
          break
      null

    getAllComponents: () -> _.values @__componentMap

    isModified : ()->
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
          if _.isEqual(backing.usage, newData.usage) and _.isEqual(backing.description, newData.description)
            return false
      true

    serialize : ( options )->

      # A hack to get around the caveat of the current framework design.
      # The Design is singleton (Because the Design is created with the mind
      # that trying to affect as little as possible of the previous system)
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
            c.serialize( component_data, layout_data, options )
            ### env:prod ###
          catch error
            console.error "Error occur while serializing", error
            ### env:prod:end ###
          finally

        else
          console.error "Serializing an connection while one of the port is isRemoved() or null"


      # Explicitly create the json. Since we don't really know what might
      # exist in the `attributes`.
      layout_data.size = @attributes.canvasSize

      attr = @attributes
      data = {
        id            : @__opsModel.get("id")
        region        : @__opsModel.get("region")
        provider      : @__opsModel.get("provider")
        time_update   : @__opsModel.get("updateTime")
        usage         : attr.usage
        version       : OpsModel.LatestVersion
        host          : attr.host
        property      : attr.property || {}
        description   : attr.description
        resource_diff : attr.resource_diff
        agent         : attr.agent
        name          : attr.name
        stack_id      : attr.stack_id
        type          : attr.type
        component     : component_data
        layout        : layout_data
      }


      # At this point, we allow each visitors to have full privilege to modify
      # the component data. This is necessary for visitors that wants to work on
      # many components at once. ( One use-case is Subnet would like to assign IPs. )
      for visitor in @constructor.__serializeVisitors || []
        visitor( component_data, layout_data, options )

      if currentDesignObj
        currentDesignObj.use()

      data


    serializeAsStack : (new_name)->
      json = @serialize( { toStack : true } )
      json.name = new_name||json.name
      delete json.stack_id
      json


    preserveName : ()->
      if not @modeIsAppEdit() then return
      @__preservedNames = {}
      for uid, comp of @__componentMap
        names = @__preservedNames[ comp.type ] || ( @__preservedNames[ comp.type ] = {} )
        names[ comp.get("name") ] = true
      return

    isPreservedName : ( type, name )->
      if not @modeIsAppEdit() then return false
      if not @__preservedNames then return false
      names = @__preservedNames[type]
      names and names[name]

    getCost : (stopped)-> { costList : [], totalFee : 0 }

  }, {
    MODE:
      Stack   : "stack"
      App     : "app"
      AppEdit : "appedit"

    EVENT:
      # Events that will trigger using Design.trigger

      # Events that will trigger using Design.instance().trigger
      ChangeResource : "CHANGE_RESOURCE"

      # Events that will trigger both using Design.trigger and Design.instance().trigger
      AddResource     : "ADD_RESOURCE"
      RemoveResource  : "REMOVE_RESOURCE"
      Deserialized    : "DESERIALIZED"  # This event is used by the internal resource model to get notified when the deserialization is done.
      DidDeserialized : "DIDDESERIALIZED" # This event is used by external objects which want to know when the design finish deserialization.


    registerModelClass : ( type, modelClass, resolveFirst )->
      __modelClassMap[ type ] = modelClass
      if resolveFirst
        __resolveFirstMap[ type ] = resolveFirst
      null

    registerSerializeVisitor : ( func )->
      if not @__serializeVisitors
        @__serializeVisitors = []
      @__serializeVisitors.push func
      null

    registerDeserializeVisitor : ( func )->
      if not @__deserializeVisitors
        @__deserializeVisitors = []
      @__deserializeVisitors.push func
      null

    instance : ()-> __instance
    modelClassForType : ( type )-> __modelClassMap[ type ]
    modelClassForPorts : ( port1, port2 )->
      l = __modelClassMap[ port1 + ">" + port2 ]
      if l then return l
      __modelClassMap[ port2 + ">" + port1 ]

    lineModelClasses : ()->
      if @__lineModelClasses then return @__lineModelClasses

      @__lineModelClasses = cs = []
      for type, modelClass of __modelClassMap
        # Ignore every type that has ">", because that's duplicated class for a line.
        if modelClass.__isLineClass and type.indexOf(">") is -1
          cs.push modelClass

      @__lineModelClasses
  }

  _.extend Design, Backbone.Events

  Design
