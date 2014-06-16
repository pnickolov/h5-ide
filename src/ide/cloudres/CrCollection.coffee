
define ["ApiRequest", "./CrModel", "constant", "backbone"], ( ApiRequest, CrModel, constant )->

  SubCollections = {}
  emptyArr = []
  SubColsByAwsResType = {}

  # Need unify list group by resource type
  __needUnifyList =

    INSTANCE:
        networkInterfaces   : 'networkInterfaceSet'
        state               : 'instanceState'
        securityGroups      : 'groupSet'
        blockDeviceMappings : 'blockDeviceMapping'

    ELB:
        GroupSet: 'SecurityGroups',


    # All resource type will be replaced in below list
    ALL:
      associations: 'associationSet'
      privateIpAddresses: 'privateIpAddressesSet'
      groups: 'groupSet'


  __needUnify = ( type ) ->
    all = __needUnifyList.ALL
    longTypeList = constant.WRAP __needUnifyList
    _.extend all, longTypeList[ type ]

  __replaceKey = ( obj, oldKey, newKey ) ->
    obj[ newKey ] = obj[ oldKey ]
    delete obj[oldKey]

  __camelToPascal = ( obj ) ->
    exceptionList = [ 'member', 'item' ]

    for k, v of obj
      newKey = k.substring(0,1).toUpperCase() + k.substring(1)
      if k not in exceptionList and newKey isnt k
        __replaceKey obj, k, newKey

  __replaceKeyInList = ( obj, type ) ->
    needReplaceList = __needUnify type

    for k, v of obj
      if k in _.keys needReplaceList
        __replaceKey obj, k, needReplaceList[ k ]



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
            if self.trAwsXml
              data = self.trAwsXml( data )

            if self.parseFetchData and data
              data = self.parseFetchData( data )

            if not data then data = emptyArr
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
    __parseExternalData : ( awsData, extraAttr )->
      try
        if @parseExternalData
          awsData = @parseExternalData( awsData )
        else
          awsData = @parseFetchData( awsData )
      catch e
        return null

      if not awsData or not awsData.length
        @trigger "update"
        return

      # Transform the data id if the Collection has defined it.
      toAddIds = []
      for d in awsData
        if @modelIdAttribute
          d.id = d[ @modelIdAttribute ]
          delete d[ @modelIdAttribute ]

        toAddIds.push d.id

      # Remove models first, then add new one.s
      @remove toAddIds, {silent:true}
      @add awsData, extraAttr
      return


      data


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

    convertBoolAndNumToString: ( obj ) ->

      for camelKey, value of obj
        if not (obj.hasOwnProperty camelKey) then continue
        if _.isObject(obj[camelKey]) or _.isArray(obj[camelKey])
          @convertBoolAndNumToString value
        else if _.isBoolean(obj[camelKey]) or _.isNumber(obj[camelKey])
            obj[camelKey] = String(obj[camelKey])

      obj

    unifyApi: ( obj, type ) ->
      hit = false
      if not _.isObject obj then return obj

      for key, value of obj
        if not (obj.hasOwnProperty key) then continue

        if not _.isArray( obj )
          __replaceKeyInList obj, type
          hit = true

        @unifyApi value, type if not hit

      obj

    camelToPascal: ( obj ) ->
      exceptionList = [ 'member', 'item' ]
      if not _.isObject obj then return obj

      for camelKey, value of obj
        if not (obj.hasOwnProperty camelKey) then continue

        pascalKey = camelKey.substring(0,1).toUpperCase() + camelKey.substring(1)
        if not _.isArray( obj ) and pascalKey isnt camelKey and camelKey not in exceptionList
          obj[pascalKey] = value
          delete obj[camelKey]

        @camelToPascal value

      obj

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
