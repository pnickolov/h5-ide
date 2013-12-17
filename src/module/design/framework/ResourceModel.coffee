
define [ "Design", "backbone" ], ( Design )->

  ###
    -------------------------------
     ResourceModel is the base class to implment a AWS Resource.

     [FORCE] means method of base class will be called, even if it's overriden.
    -------------------------------


    ++ Class Method ++

    # extend( protoProps, overrideArray, staticProps ) : ResourceModelSubClass
        description : returns a subClass of ResourceModel

    # deserialize()
        description : Must be implemented by the user, otherwise it logs an error in console.

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

    # isRemovable() : Boolean / Object / String
        description : Returns true to indicate the resource can be removed. Returns string to show as an warning asking user if he/she wants to delete anyway. Returns {error:String} to show as an error.

    # isReparentable( newParent ) : Boolean / String
        description : Returns true to indicate the resource can change to other parent. Returns string to show as an error.

    # remove() : [FORCE]
        description : Just like the destructor in C++. User can override this method.
        The framework will ensure the base class's remove() will get called.
        This method will fire "REMOVED" event when called.

    # initialize() : [FORCE]
        description : The same as Backbone.Model.initialize()


    # serialize()
        description : Must be implemented by the user, otherwise it logs an error in console.

    # listenTo()
        description : listenTo() is a convinant method for on().
        Benifits is that when this resource is removed, it will automatically unListen everything it previous listened to. Side-effects are the context of the callback will always be this.

    # storage()
    # getFromStorage( filter )
    # addToStorage( resouceModel )
        description : One can store resourceModels into this.storage().
        According to `Backbone.Collection.model` and `Backbone.Collection.create()`, collection is ususally used to store the same type/kind of objects.
        Practically speaking, using this.storage() ( especially using it store different kinds of objects ) are unreasonable. It is uncertain if something is inside this.storage(), thus making it hard to manage these things.
        Better not to use this api.

  ###

  # FORCE_MAP defines what parent method will be called when child's overriden method is called
  FORCE_MAP = [ "remove", "initialize", "connect", "addChild", "disconnect" ]

  ResourceModel = Backbone.Model.extend {

    classId : _.uniqueId("dfc_")
    type    : "Framework_R"

    # Associate Map, consisted of key, type and suffix
    __asso: []

    # Do Associate, bind asso to the couple model
    associate: ( resolve, uid ) ->
      if resolve instanceof ResourceModel
        model = resolve
        @addToStorage model
        model.addToStorage @
      else if uid
        model = resolve uid
        @associate model
      else
        for attr in @__asso
          arns = @get attr.key
          if _.isString arns
            arns = [ arns ]
          if _.isArray arns
            for arn in arns
              uid = MC.extractID arn
              model = resolve uid
              @associate model
            @unset attr.key
      null

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

    addToStorage : ( resource ) ->
      storage = this.storage()
      storage.add resource
      null

    constructor : ( attributes, options )->

      if not attributes
        attributes = {}

      # Assign new GUID
      if not attributes.id
        attributes.id = MC.guid()

      # Assign new name
      if not attributes.name
        attributes.name = @getNewName()

      Backbone.Model.call this, attributes, options

      # Cache the object inside the current design.
      design = Design.instance()
      design.classCacheForCid( this.classId ).push( this )
      design.cacheComponent( this.id, this )

      this

    getNewName : ()->
      if not @newNameTmpl then return ""

      myKinds = Design.modelClassForType( @type ).allObjects()
      base = myKinds.length + 1
      while true
        newName = @newNameTmpl + base
        same    = false
        for k in myKinds
          if k.get("name") is newName
            same = true
            break

        if not same then break
        base += 1

      newName

    hasAppResource : ()->
        region = MC.canvas_data.region
        resourceId = @get("appId")
        if MC.data.resource_list[region][resourceId]
          return true

        return false

    isRemovable : () -> true
    isReparentable : ()-> true

    destroy : ()-> @remove()

    remove : ()->
      console.debug "ResourceModel.remove"

      # Clean up reference
      design = Design.instance()
      cache = design.classCacheForCid( this.classId )
      cache.splice( cache.indexOf( this ), 1 )
      design.cacheComponent( this.id )

      # Clear all events attached to others using listenTo
      if this.__interestedObj
        for uid, obj in this.__interestedObj
          obj = design.component( uid )
          if obj then obj.off( null, null, this )
        this.__interestedObj = null

      # Storage is not automatically cleared.

      # Broadcast remove event
      this.trigger "REMOVED"
      # Also trigger a destroy event for Backbone.
      this.trigger "destroy"

      # Clear all events attached to me
      this.off()
      null

    isTypeof : ( type )->
      c = this
      while c
        if c.type is type
          return true
        c = c.constructor.__super__

      return false


    serialize : ()->
      console.error "Class '#{@type}' doesn't implement serialize"
      null

    listenTo : ( other_resource, event, callback )->
      if not this.__interestedObj
        this.__interestedObj = {}
      this.__interestedObj[ other_resource.id ] = true

      other_resource.on( event, callback, this )
      null
  }, {

    allObjects : ()->
      Design.instance().classCacheForCid( this.prototype.classId ).slice(0)

    deserialize : ()->
      console.error "Class '#{@.prototype.type}' doesn't implement deserialize"
      null

    extend : ( protoProps, staticProps ) ->

      console.assert protoProps.type, "Subclass of ResourceModel does not specifying a type"

      if _.has(protoProps, 'constructor')
        console.warn "Subclass of ResourceModel (type : #{protoProps.type}) is overriding Constructor, don't forget to call 'this.constructor.__super__.constructor' !"

      if staticProps and staticProps.handleTypes
        handleTypes = staticProps.handleTypes
        delete staticProps.handleTypes

      ### jshint -W083 ###
      for m in FORCE_MAP
        parentMethod = this.prototype[m]
        if protoProps[ m ] and parentMethod

          protoProps[ m ] = (()->
            childImpl  = protoProps[m]
            parentImpl = parentMethod
            ()->
              ret = childImpl.apply( this, arguments )
              parentImpl.apply( this, arguments )
              ret
          )()
      ### jshint +W083 ###

      protoProps.classId = _.uniqueId("dfc_")

      # Create subclass
      subClass = Backbone.Model.extend.call( this, protoProps, staticProps )

      # Register this class, so that Design knows this class can handle resources.
      if handleTypes
        if _.isString( handleTypes )
          handleTypes = [ handleTypes ]

        for type in handleTypes
          Design.registerModelClass type, subClass, staticProps.resolveFirst

      subClass
  }

  ResourceModel

