
define ["ApiRequest", "./CrModel", "backbone"], ( ApiRequest, CrModel )->

  SubCollections = {}
  emptyArr = []
  SubColsByAwsResType = {}

  Backbone.Collection.extend {

    category : ""
    model    : CrModel
    #modelIdAttribute : ""
    #AwsResponseType  : ""

    constructor : ()->
      @on "add remove", (_.debounce ()-> @trigger "update"), @
      Backbone.Collection.apply this, arguments

    isReady : ()-> @__fetchPromise && this.__ready

    # Fetch the data from AWS. The data is only fetched once even if called multiple time.
    fetch : ()->
      if @__fetchPromise then return @__fetchPromise

      @lastFetch = +new Date()
      @__ready = false

      self = @
      @__fetchPromise = @doFetch().then ( data )->

        if not self.__selfParseData
          try
            data = self.parseFetchData( data ) || emptyArr
          catch e
            throw McError( ApiRequest.Errors.InvalidAwsReturn, "", data )

          # Transform the data id if the Collection has defined it.
          if self.modelIdAttribute
            for d in data
              d.id = d[ self.modelIdAttribute ]
              delete d[ self.modelIdAttribute ]

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

    # This method is used by CloudResources to provide an external api to parse data coming from aws.
    # It parse data and the cached them in this collection and returns parsed models.
    parseExternalData : ( awsData )->
      try
        awsData = @parseFetchData( awsData )
      catch e
        return null

      # Transform the data id if the Collection has defined it.
      if @modelIdAttribute
        for d in awsData
          d.id = d[ @modelIdAttribute ]
          delete d[ @modelIdAttribute ]

      @add awsData
      return

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

    # Override Backbone.Collection.where
    where : ( option, first )->
      if option.category and option.category is @category
        delete option.category

      for key of option
        if option.hasOwnProperty( key )
          hasOtherAttr = true
          break

      if hasOtherAttr
        res = Backbone.Collection.prototype.where.call( this, option ) || []
      else
        res = @models.slice(0)

      if first then res[0] else res

  }, {

    # CloudResources uses this method to get the right category.
    # Subclass of CrCollection can override this method to cast one category to another.
    category : ( category )-> category

    # CloudResources uses these method to get the right Class of Collection.
    getClassByType : ( id )-> SubCollections[id]
    # The typeString should be something like "DescribeNetworkInterfacesResponse"
    getClassByAwsResponseType : ( typeString )-> SubColsByAwsResType[ typeString ]


    extend : ( protoProps, staticProps ) ->
      console.assert protoProps.type, "Subclass of CloudResourceCollection does not specifying a type"

      if protoProps.AwsResponseType
        AwsResponseType = protoProps.AwsResponseType
        delete protoProps.AwsResponseType

      staticProps = staticProps || {}
      staticProps.type = protoProps.type

      # Create subclass
      subClass = CrModel.extend.call( this, protoProps, staticProps )

      SubCollections[ protoProps.type ] = subClass
      if AwsResponseType
        SubColsByAwsResType[ AwsResponseType ] = subClass

      subClass
  }
