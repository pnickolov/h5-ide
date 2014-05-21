
define ["backbone"], ()->

  SubCollections = {}

  Backbone.Collection.extend {

    category : ""

    __debounceUpdate : _.debounce ()-> @trigger "update"

    constructor : ()->
      @on "add remove", @__debounceUpdate, @
      @

    # Fetch the data from AWS. The data is only fetched once even if called multiple time.
    fetch : ()->
      if @fetchPromise then return @fetchPromise

      @lastFetch = +new Date()

      self = @
      @fetchPromise = @doFetch().then ( res )->
        try
          self.set( self.parseFetchData(res) )
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "", res )

        console.info "DHCP", self
        return self
      , ()->
        @lastFetch = 0
        self.fetchPromise = null

      @fetchPromise

    # Force to fetch the data
    fetchForce : ()->
      @fetchPromise = null
      @fetch()

    # Force to fetch the data only if the data is consider to be invalid
    fetchIfExpired : ()->
      lastFetch = @lastFetch || 0
      if (+new Date()) - lastFetch < 1800000
        console.info "The collection is not expired,", @
        return
      @fetchPromise = null
      @fetch()

    # Override this method to parse the result of the fetch.
    parseFetchData : ( res )-> res

    # Destroy the collection. Most of the collection should not be destroy.
    destroy : ()-> @trigger "destroy", @id

    # Returns a newly created model. The model is not saved to AWS yet, so there's not
    # add event.
    create : ( attributes )-> new @model( attributes )

  }, {

    # CloudResources uses this method to get the right category.
    # Subclass of CrCollection can override this method to cast one category to another.
    category : ( category )-> category

    # CloudResources uses these method to get the right Class of Collection.
    classId      : ( resourceType, platform )-> (platform || "AWS") + "_" + resourceType
    getClassById : ( id )-> SubCollections[id]

    ### env:dev ###
    __detailExtend : ( protoProps, staticProps, funcName )->
      ### jshint -W061 ###

      parent = this

      funcName = protoProps.type.split(".").pop() + ( funcName || "Collection" )
      childSpawner = eval( "(function(a) { var #{funcName} = function(){ return a.apply( this, arguments ); }; return #{funcName}; })" )

      if protoProps and protoProps.hasOwnProperty "constructor"
        cstr = protoProps.constructor
      else
        cstr = ()-> return parent.apply( this, arguments )

      child = childSpawner( cstr )

      _.extend(child, parent, staticProps)

      funcName = "PROTO_CR_" + funcName
      prototypeSpawner = eval( "(function(a) { var #{funcName} = function(){ this.constructor = a }; return #{funcName}; })" )

      Surrogate = prototypeSpawner( child )
      Surrogate.prototype = parent.prototype
      child.prototype = new Surrogate()

      if protoProps
        _.extend(child.prototype, protoProps)

      child.__super__ = parent.prototype
      ### jshint +W061 ###

      child
    ### env:dev ###

    extend : ( protoProps, staticProps ) ->
      console.assert protoProps.type, "Subclass of CloudResourceCollection does not specifying a type"

      # Create subclass
      subClass = (@__detailExtend || Backbone.Collection.extend).call( this, protoProps, staticProps )

      SubCollections[ @classId( protoProps.type, protoProps.platform ) ] = subClass

      subClass
  }
