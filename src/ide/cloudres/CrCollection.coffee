
define ["ApiRequest", "backbone"], ( ApiRequest )->

  SubCollections = {}

  Backbone.Collection.extend {

    category : ""

    constructor : ()->
      @on "add remove", (_.debounce ()-> @trigger "update"), @
      Backbone.Collection.apply this, arguments

    isReady : ()-> @__fetchPromise && self.__ready

    # Fetch the data from AWS. The data is only fetched once even if called multiple time.
    fetch : ()->
      if @__fetchPromise then return @__fetchPromise

      @lastFetch = +new Date()
      @__ready = false

      self = @
      @__fetchPromise = @doFetch().then ( data )->

        if not self.__selfParseData
          try
            data = self.parseFetchData( data )
          catch e
            throw McError( ApiRequest.Errors.InvalidAwsReturn, "", data )

        self.__ready = true
        if data.length is 0 and self.models.length is 0
          # In the initial state, even if we fetches an empty array of data.
          # We still want to trigger a `update` to broadcast that we finished fetching.
          self.trigger "update"
        else
          self.set data

        return self

      , ( error )->
        self.lastFetch = 0
        self.__fetchPromise = null
        throw error

      @__fetchPromise

    # Force to fetch the data
    fetchForce : ()->
      @__fetchPromise = null
      @reset() # Clear all the datas in the collection before fetching.
      @trigger "update" # Also trigger an update event for others know that the collection is emptied.
      @fetch()

    # Force to fetch the data only if the data is consider to be invalid
    fetchIfExpired : ()->
      lastFetch = @lastFetch || 0
      if (+new Date()) - lastFetch < 1800000
        console.info "The collection is not expired,", @
        return
      @__fetchPromise = null
      @fetch()

    # Override this method to parse the result of the fetch.
    parseFetchData : ( res )-> res

    # Destroy the collection. Most of the collection should not be destroy.
    destroy : ()-> @trigger "destroy", @id

    # Returns a newly created model. The model is not saved to AWS yet, so there's not
    # add event.
    create : ( attributes )->
      m = new @model( attributes )
      m.__collection = @
      m

    region : ()-> @category

  }, {

    # CloudResources uses this method to get the right category.
    # Subclass of CrCollection can override this method to cast one category to another.
    category : ( category )-> category

    # CloudResources uses these method to get the right Class of Collection.
    classId      : ( resourceType, platform )-> (platform || "AWS") + "_" + resourceType
    getClassById : ( id )-> SubCollections[id]

    ### env:dev ###
    __detailExtend : ( protoProps, staticProps )->
      ### jshint -W061 ###

      parent = this

      funcName = protoProps.ClassName || protoProps.type.split(".").pop()
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

    extend : ( protoProps, staticProps ) ->
      console.assert protoProps.type, "Subclass of CloudResourceCollection does not specifying a type"

      # Create subclass
      subClass = (@__detailExtend || Backbone.Collection.extend).call( this, protoProps, staticProps )

      SubCollections[ @classId( protoProps.type, protoProps.platform ) ] = subClass

      subClass
  }
