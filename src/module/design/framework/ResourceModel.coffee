
define [ "./Design", "backbone" ], ( Design )->

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


    ++ Object Method ++

    # allObjects() : Array
        description : returns a array containing all objects of this type of Model.

    # isRemovable() : Boolean / String
        description : returns true to indicate the resource can be removed. returns a string as an error message to indicate the resource cannot be removed.

    # remove() : [FORCE]
        description : Just like the destructor in C++. User can override this method.
        The framework will ensure the base class's remove() will get called.
        This method will fire "REMOVED" event when called.

    # initialize() : [FORCE]
        description : The same as Backbone.Model.initialize()


    # serialize()
        description : Must be implemented by the user, otherwise it logs an error in console.

  ###

  # FORCE_MAP defines what parent method will be called when child's overriden method is called
  FORCE_MAP = [ "remove", "initialize", "connect", "addChild" ]

  ResourceModel = Backbone.Model.extend {

    classId : _.uniqueId("dfc_")
    type   : "Framework_R"

    constructor : ( attributes, options )->

      # Assign a new GUID to this object, if it don't have an id.
      if not this.id
        this.id = MC.guid()

      Backbone.Model.call this, attributes, options

      # Cache the object inside the current design.
      design = Design.instance()
      design.classCacheForCid( this.classId ).push( this )
      design.cacheComponent( this.id, this )

      this


    isRemovable : () -> true

    remove : ()->
      console.debug "ResourceModel.remove"

      # Clean up reference
      design = Design.instance()
      cache = design.classCacheForCid( this.classId )
      cache.splice( cache.indexOf( this ), 1 )
      design.cacheComponent( this.id )

      this.trigger "REMOVED"
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
          Design.registerModelClass type, subClass

      subClass
  }

  ResourceModel

