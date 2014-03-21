
define [ "Design", "event", "backbone" ], ( Design, ideEvent )->

  deepClone = ( base )->

    if base is null or not _.isObject( base )
      return base

    if _.isArray( base )
      target = []
      for a, idx in base
        target[idx] = deepClone(a)

      return target

    target = {}
    for key, value of base
      if value isnt null and _.isObject( value )
        target[ key ] = deepClone( value )
      else
        target[ key ] = value

    target


  __detailExtend = Backbone.Model.extend
  __emptyObj     = {}

  ### env:dev ###
  Attributes = ()-> this
  __checkEventOnUsage = ( protoProps )->
    ### jshint -W083 ###
    for propName, prop of protoProps
      if not _.isFunction prop then continue
      funcString = prop.toString()

      found = false
      # this.on() is allowed.
      funcString.replace /(this)?\.on\b/g, ($0, $1)->
        found = found or !$1
        found

      if found
        console.warn "Do not use Backbone.Events.on. Instead use Backbone.Events.listenTo. Found on() for resource : #{protoProps.type}"
        break
    ### jshint +W083 ###
    null

  # FORCE_MAP defines what parent method will be called when child's overriden method is called
  FORCE_MAP = [ "remove", "connect_base", "addChild", "removeChild", "disconnect_base" ]
  __checkForceMap = ( protoProps )->
    # This function is used to detect if the one of the method defined in FORCE_MAP have
    # called its super version.
    for propName, prop of protoProps
      if FORCE_MAP.indexOf(propName) is -1 and  propName isnt "constructor" then continue
      funcString = prop.toString()

      if propName is "constructor"
        p = ""
      else
        p = propName

      matchRegex = new RegExp( p + "\\.(call|apply)\\s?\\(?\\s?this" )
      if not funcString.match( matchRegex )
        console.warn "ResourceModel subclass (type : #{protoProps.type}) is overriding `#{propName}`, but it seems to forget to call Parent's method!"

    null

  __detailExtend = ( protoProps, staticProps )->
    ### jshint -W061 ###

    parent = this

    funcName = protoProps.type.replace(/\./g, "_")
    childSpawner = eval( "(function(a) { var #{funcName} = function(){ return a.apply( this, arguments ); }; return #{funcName}; })" )

    if protoProps and protoProps.hasOwnProperty "constructor"
      cstr = protoProps.constructor
    else
      cstr = ()-> return parent.apply( this, arguments )

    child = childSpawner( cstr )

    _.extend(child, parent, staticProps)

    funcName = "PROTO_" + funcName
    prototypeSpawner = eval( "(function(a) { var #{funcName} = function(){ this.constructor = a }; return #{funcName}; })" )

    Surrogate = prototypeSpawner( child )
    Surrogate.prototype = parent.prototype
    child.prototype = new Surrogate()

    if protoProps
      _.extend(child.prototype, protoProps)

    child.__super__ = parent.prototype
    ### jshint +W061 ###

    child
  ### env:dev:end ###

  ###
    -------------------------------
     ResourceModel is the base class to implment a AWS Resource.

     [FORCE] means method of base class will be called, even if it's overriden.
    -------------------------------


    ++ Class Method ++

    # extend( protoProps, overrideArray, staticProps ) : ResourceModelSubClass
        description : returns a subClass of ResourceModel

    # preDeserialize( JSON_DATA, LAYOUT_DATA )
        description : If a Class is marked as resolveFirst, this method will be call.

    # deserialize( JSON_DATA, LAYOUT_DATA, resolve )
        description : This method is used to create objects from JSON.
        Must be implemented by the user, otherwise it logs an error in console.

    # postDeserialize( JSON_DATA, LAYOUT_DATA )
        description : This method is called after all objects are created. It's the place to create connections between objects.

    ++ Class Attributes ++

    # handleTypes : String | StringArray
                  ( Defined by user )
        description : This attribute is used to determine which ResourceModel's deserialize is called when Desin is deserializing the JSON data.

    # type : String
        description : This attribute is used for users to identify what type is the resource.

    # id : String
        description : The GUID of this component.

    # newNameTmpl : String
        description : This string is used to create a name for an resource

    ++ Object Method ++

    # allObjects() : Array
        description : returns a array containing all objects of this type of Model.

    # createRef() : String
        description : returns an string that can be used to serialized.

    # listenTo() :
        description : Override Backbone.Events.listenTo. This method will make sure that when other is removed, this will stop listen to it.

    # design() : Design
        description : returns the Design object which manages this ResourceModel object.

    # isDesignAwake() : Boolean
        description : return true if the object is in current tab. Otherwise, return false.

    # markAsRemoved() :
        description : Simple set this object as removed, so that isRemoved() will return true. Since the object will remain in cache, user still need to call remove() at appropriate time.

    # isRemoved() : Boolean
        description : return true if this object has already been removed.

    # isRemovable() : Boolean / Object / String
        description : Returns true to indicate the resource can be removed. Returns string to show as an warning asking user if he/she wants to delete anyway. Returns {error:String} to show as an error.

    # isReparentable( newParent ) : Boolean / String
        description : Returns true to indicate the resource can change to other parent. Returns string to show as an error.

    # cloneAttributes() :
        description : A helper function to allow ChildClass to implement clone(). More details, see InstanceModel

    # remove() : [FORCE]
        description : Just like the destructor in C++. User can override this method.
        The framework will ensure the base class's remove() will get called.
        This method will fire "destroy" event when called.

    # initialize() : [FORCE]
        description : The same as Backbone.Model.initialize()

    # constructor() :
        description : new Model() will call constructor. If a model wants to create an object, it needs to call SuperClass's constructor. Otherwise, the object is consider not created.


    # serialize()
        description : Must be implemented by the user, otherwise it logs an error in console.

    # storage()
    # getFromStorage( filter )
    # addToStorage( resouceModel )
        description : One can store resourceModels into this.storage().
        According to `Backbone.Collection.model` and `Backbone.Collection.create()`, collection is ususally used to store the same type/kind of objects.
        Practically speaking, using this.storage() ( especially using it store different kinds of objects ) are unreasonable. It is uncertain if something is inside this.storage(), thus making it hard to manage these things.
        Better not to use this api.

  ###

  ResourceModel = Backbone.Model.extend {

    classId : _.uniqueId("dfc_")
    type    : "Framework_R"

    constructor : ( attributes, options )->

      # Remember current design object
      # So that later, we can check if this object's design is showing
      design = Design.instance()
      this.__design = design

      if not attributes
        attributes = {}

      # Assign new GUID
      if not attributes.id
        attributes.id = design.guid()

      # Assign new name
      if not attributes.name
        attributes.name = @getNewName()
        if not attributes.name then delete attributes.name

      # Cache the object inside the current design.
      design.classCacheForCid( this.classId ).push( this )
      design.cacheComponent( attributes.id, this )

      Backbone.Model.call( this, attributes, options || __emptyObj )

      ### env:dev ###
      @attributes = _.extend( new Attributes(), @attributes )
      ### env:dev:end ###

      # Initialize name/appId to empty string
      if not @attributes.name  then @attributes.name  = ""
      if not @attributes.appId then @attributes.appId = ""

      # Trigger Design AddResource Event here.
      # Because only at this time, the resource is fully created.
      Design.trigger Design.EVENT.AddResource, this

      this

    getNewName : ( base )->
      if not @newNameTmpl
        newName = if @defaults then @defaults.name
        return newName or ""

      if base is undefined
        myKinds = Design.modelClassForType( @type ).allObjects()
        base = myKinds.length

      # Collect all the resources name
      nameMap = {}
      @design().eachComponent ( comp )->
        if comp.get("name")
          nameMap[ comp.get("name") ] = true
        null

      while true
        newName = @newNameTmpl + base
        if nameMap[ newName ]
          base += 1
        else
          break

      newName

    hasAppResource : ()->
      if not Design.instance().modeIsStack() and @.get("appId")
        !!@get("appId") and MC.data.resource_list[ Design.instance().region() ][ @get("appId") ]
      else
        true


    isDesignAwake : ()-> Design.instance() is @__design
    design : ()-> @__design

    getAllObjects : ( awsType )->
      if not awsType then awsType = @type
      @design().classCacheForCid( this.prototype.classId ).slice(0)

    markAsRemoved : ( isRemoved )->
      if isRemoved is undefined
        @__isRemoved = true
      else
        @__isRemoved = !!isRemoved
      null

    isRemoved   : ()-> @__isRemoved is true
    isRemovable : () -> true
    isReparentable : ()-> true

    ### env:dev ###
    isTypeof : ( type )->
      c = this
      while c
        if c.type is type
          return true
        ### jshint -W103 ###
        c = c.__proto__
        ### jshint +W103 ###

      return false
    ### env:dev:end ###


    serialize : ()->
      console.warn "Class '#{@type}' doesn't implement serialize"
      null

    destroy : ()-> @remove()

    remove : ()->
      if @isRemoved()
        console.warn "The resource is already removed : ", this
        return

      @__isRemoved = true

      console.debug "Removing resource : #{@get('name')}", this

      # Clean up reference
      design = Design.instance()
      cache = design.classCacheForCid( this.classId )
      cache.splice( cache.indexOf( this ), 1 )
      design.cacheComponent( this.id )

      # Clear all events attached to others using listenTo
      @stopListening()

      # Storage is not automatically cleared.

      # Broadcast destroy event.
      this.trigger "destroy", this

      this.trigger "__remove"

      # Clear all events attached to me
      this.off()

      this.__design = null

      # Trigger Design RemoveResource Event here.
      # Because only at this time, the resource is fully removed.
      Design.trigger Design.EVENT.RemoveResource, this
      null

    createRef : ( refName, isResourceNS, id )->
      if _.isString( isResourceNS )
        id = isResourceNS
        isResourceNS = true

      id = id or @id
      if not id then return ""

      if isResourceNS isnt false
        MC.aws.aws.genResRef(id, "resource.#{refName}")
        # "@#{id}.resource.#{refName}"
      else
        MC.aws.aws.genResRef(id, "#{refName}")
        # "@#{id}.#{refName}"

    listenTo : ( other, event, callback )->
      # Override Backbone.Events.listenTo.
      # This method will make sure that when other is removed, this will stop listen to it.

      model = Design.modelClassForType other.type
      if model and ( not this._listeners or not this._listeners[ other._listenerId ] )
        # The `other` is a ResourceModel that is registered in Design.
        # We should stopListening once the `other` is removed
        that = this
        other.once "__remove", ()-> that.stopListening( this ) # this here is `other`

      Backbone.Events.listenTo.call this, other, event, callback


    # Do Associate, bind asso to the couple model
    associate: ( resolve, uid ) ->
      # Associate Map, consisted of key, type and suffix
      if not @__asso
        @__asso = []
      if resolve instanceof ResourceModel
        model = resolve
        @addToStorage model
        model.addToStorage @
      else if _.isFunction resolve
        if uid
          model = resolve uid
          @associate model
        else
          for attr in @__asso
            keys = attr.key.split '.'
            masterKey = keys.pop()
            arns = @get keys

            for k in keys
              arns = arns[ k ]

            if _.isString arns
              arns = [ arns ]

            if _.isArray arns
              for arn in arns
                uid = MC.extractID arn
                model = resolve uid
                if model
                  @associate model
              if not keys.length
                @unset attr.key
      null

    disassociate: ( filter ) ->
      removed = @removeFromStorage filter
      for model in removed
        model.removeFromStorage @

    cloneAttributes : ( srcTarget, option )->
      console.assert srcTarget.type is @type, "Invalid type of target when cloning attributes."

      # option =
      #   reserve : "id|appId|x|y|width|height"
      #   copyConnection : [ "KeypairUsage", "SgAsso" ]

      option = option or {}
      extraReserve = option.reserve or ""
      reserve = "id|appId|x|y|width|height|name"
      cnsType = option.copyConnection or []

      for attr, value of srcTarget.attributes
        if attr.indexOf("__") is 0 or reserve.indexOf( attr ) isnt -1 or extraReserve.indexOf( attr ) isnt -1
          continue

        if value isnt null and _.isObject( value )
          value = @cloneObjectAttributes( attr, value )

        @attributes[ attr ] = value

      # Copy connection
      for cnType in cnsType
        CnClass = Design.modelClassForType( cnType )
        for target in srcTarget.connectionTargets( cnType )
          new CnClass( target, this )
      null

    cloneObjectAttributes : ( attributeName, attributeValue )->
      # Cannot use $.extend here, because $.extend does not deep copy user-defined-objects.
      deepClone( attributeValue )

    # Storage is created when necessary
    storage : ()->
      if not this.__storage
        this.__storage = new Backbone.Collection()

      this.__storage

    getFromStorage : ( filter ) ->
      storage = this.storage()

      if _.isString filter
        models = _.filter storage.models, ( res )-> res.type is filter

      else if _.isFunction filter
        models = _.filter storage.models, filter

      else
        models = storage.models

      new Backbone.Collection( models )

    removeFromStorage: ( filter ) ->
      storage = this.storage()

      if _.isString filter
        models = _.filter storage.models, ( res )-> res.type is filter

      else if _.isFunction filter
        models = _.filter storage.models, filter

      else if filter instanceof ResourceModel
        models = filter

      if models
        storage.remove models
      else
        storage.reset()

      models

    addToStorage : ( resource ) ->
      storage = this.storage()
      storage.add resource
      null

  }, {

    allObjects : ()->
      # console.warn "ResourceModel.allObjects() is deprecated. Please use this.getAllObjects(awsType) instead."
      Design.instance().classCacheForCid( this.prototype.classId ).slice(0)

    deserialize : ()->
      console.error "Class '#{@.prototype.type}' doesn't implement deserialize"
      null

    extend : ( protoProps, staticProps ) ->

      console.assert protoProps.type, "Subclass of ResourceModel does not specifying a type"

      # Get handleTypes and resolveFirst
      if staticProps
        handleTypes  = staticProps.handleTypes
        resolveFirst = staticProps.resolveFirst
        delete staticProps.handleTypes
        delete staticProps.resolveFirst

      ### env:dev ###
      __checkEventOnUsage( protoProps )
      __checkForceMap( protoProps )
      ### env:dev:end ###

      ### jshint -W083 ###
      # Handle overriding methods for FORCED methods.
      # for m in FORCE_MAP
      #   parentMethod = this.prototype[m]
      #   if protoProps[ m ] and parentMethod

      #     protoProps[ m ] = (()->
      #       childImpl  = protoProps[m]
      #       parentImpl = parentMethod
      #       ()->
      #         ret = childImpl.apply( this, arguments )
      #         parentImpl.apply( this, arguments )
      #         ret
      #     )()
      ### jshint +W083 ###

      protoProps.classId = _.uniqueId("dfc_")

      # Create subclass
      subClass = __detailExtend.call( this, protoProps, staticProps )

      # Register this class, so that Design knows this class can handle resources.
      if not handleTypes then handleTypes = protoProps.type

      if handleTypes
        if _.isString( handleTypes )
          handleTypes = [ handleTypes ]

        for type in handleTypes
          Design.registerModelClass type, subClass, resolveFirst

      subClass
  }

  Design.registerModelClass ResourceModel.prototype.type, ResourceModel

  ResourceModel

