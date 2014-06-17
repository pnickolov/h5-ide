
define ["ApiRequest", "./CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  OS_TYPE_LIST = ['centos','redhat','rhel','ubuntu','debian','fedora','gentoo','opensuse','suse','amazon','amzn']
  SQL_WEB_PATTERN      = /sql.*?web.*?/i
  SQL_STANDARD_PATTERN = /sql.*?standard.*?/i

  INVALID_AMI_ID = /\[(.+?)\]/
  MALFORM_AMI_ID = /\s["|'](.+?)["|']/

  ### Helpers ###
  getOSType = ( ami ) ->
    #return osType by ami.name | ami.description | ami.imageLocation
    if ami.osType then return ami.osType

    if ami.platform is "windows" then return "windows"

    name   = (ami.name || "").toLowerCase()
    desc   = (ami.description || "").toLowerCase()
    imgloc = (ami.imageLocation || "").toLowerCase()

    for word in OS_TYPE_LIST
      if name.indexOf( word ) >= 0
        osType = word
        break

      if desc.indexOf( word ) >= 0
        osTypeGuess1 = word
      if imgloc.indexOf( word ) >= 0
        osTypeGuess2 = word

    osType = osType || osTypeGuess1 || osTypeGuess2 || "linux-other"

    if osType is "rhel" then return "redhat"
    if osType is "amzn" then return "amazon"

    osType


  getOSFamily = ( ami ) ->
    if not ami.osType then return "linux"

    osType = ami.osType

    if constant.OS_TYPE_MAPPING[ osType ]
      osFamily = constant.OS_TYPE_MAPPING[ osType ]

    if osType in constant.WINDOWS
      osFamily = 'mswin'

      if SQL_WEB_PATTERN.exec(ami.name || "") or SQL_WEB_PATTERN.exec(ami.description || "") or SQL_WEB_PATTERN.exec(ami.imageLocation || "")
        return "mswinSQLWeb"

      if SQL_STANDARD_PATTERN.exec(ami.name || "") or SQL_STANDARD_PATTERN.exec(ami.description || "") or SQL_STANDARD_PATTERN.exec(ami.imageLocation || "")
        return "mswinSQL"

    osFamily

  fixDescribeImages = ( amiArray )->
    ms = []
    for ami in amiArray
      ami.id = ami.imageId
      delete ami.imageId

      bdm = {}
      for item in ami.blockDeviceMapping?.item || []
        bdm[ item.deviceName ] = item.ebs || {}

      ami.osType   = getOSType( ami )
      ami.osFamily = getOSFamily( ami )

      delete ami.blockDeviceMapping
      ms.push ami.id
    ms

  ### This Collection is used to fetch generic ami ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrAmiCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.AMI

    __selfParseData : true
    doFetch : ()->
      # This method is used for CloudResources to invalid the cache.
      localStorage.setItem("invalidAmi/" + @region(), "")
      @__invalids = {}
      d = Q.defer()
      d.resolve([])
      @trigger "update"
      return d.promise

    initInvalidateId : ()->
      invalidAmi = localStorage.getItem("invalidAmi/" + @region())
      @__invalids = {}

      if invalidAmi
        for id in invalidAmi.split(",")
          @__invalids[ id ] = true
      return

    invalidate : ( amiId )-> @__invalids[ amiId ] = true
    isValidId  : ( amiId )-> !@__invalids[ amiId ]

    saveInvalidAmiId : ()->
      amis = []
      for amiId, value of @__invalids
        amis.push amiId

      localStorage.setItem("invalidAmi/" + @region(), amis.join(",") )

    fetchAmis : ( amis )->
      if not @__invalids then @initInvalidateId()

      if not amis then return

      if _.isString(amis)
        amis = [amis]

      # See if we ha
      toFetch = []
      for amiId in amis
        if @get( amiId ) then continue
        if not @isValidId( amiId )
          console.warn "Ami '#{amiId}' is not valid. Ignoring."
          continue
        toFetch.push( amiId )

      if toFetch.length is 0
        d = Q.defer()
        d.resolve()
        return d.promise

      self = @

      # Do fetch.
      ApiRequest("ami_DescribeImages", {
        region_name : @region()
        ami_ids     : toFetch
      }).then ( res )->
        res = res.DescribeImagesResponse.imagesSet?.item
        if res
          fixDescribeImages( res )
          self.add res, {add: true, merge: true, remove: false}
        else
          self.trigger "update"

        self.saveInvalidAmiId()

      , ( err )->
        if err.awsErrorCode is "InvalidAMIID.NotFound"
          # The image id '[ami-00000123]' does not exist
          invalidId = INVALID_AMI_ID.exec err.awsResult
        else if err.awsErrorCode is "InvalidAMIID.Malformed"
          # Invalid id: "ami-"
          invalidId = MALFORM_AMI_ID.exec err.awsResult

        if not invalidId
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Can't describe AMIs and AWS returns invalid data. Please contact us when you encouter this issue.", toFetch )

        invalidId = invalidId[1]

        console.info "The requested Ami '#{invalidId}' is invalid, retrying to fetch"

        toFetch.splice( toFetch.indexOf(invalidId), 1 )
        self.invalidate( invalidId )
        self.fetchAmis( toFetch )
  }


  SpecificAmiCollection = CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSpecificAmiCollection"
    ### env:dev:end ###

    type : "SpecificAmiCollection"

    initialize : ()-> @__models = []; return

    getModels : ()->
      ms = []
      col = CloudResources( constant.RESTYPE.AMI, @region() )
      for id in @__models
        ms.push col.get( id )
      ms

    fetchForce : ()->
      @__models = []
      CrCollection.prototype.fetchForce.call this



  }

  ### This Collection is used to fetch quickstart ami ###
  SpecificAmiCollection.extend {
    ### env:dev ###
    ClassName : "CrQuickstartAmiCollection"
    ### env:dev:end ###

    type  : "QuickStartAmi"

    doFetch : ()-> ApiRequest("aws_quickstart", {region_name : @region()})

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      savedAmis = []
      amiIds  = []
      for id, ami of data
        ami.id = id
        savedAmis.push ami
        amiIds.push id

      CloudResources( constant.RESTYPE.AMI, @region() ).add savedAmis
      @__models = amiIds
      return
  }




  ### This Collection is used to fetch my ami ###
  SpecificAmiCollection.extend {
    ### env:dev ###
    ClassName : "CrMyAmiCollection"
    ### env:dev:end ###

    type  : "MyAmi"

    doFetch : ()->
      selfParam1 =
        region_name   : @region()
        executable_by : ["self"]
        filters       : [{ Name : "is-public", Value : false }]
      selfParam2 =
        region_name   : @region()
        owners        : ["self"]

      self = @

      Q.allSettled([
        ApiRequest("ami_DescribeImages", selfParam1)
        ApiRequest("ami_DescribeImages", selfParam2)
      ]).spread ( d1, d2 )->
        d1 = d1.value.DescribeImagesResponse.imagesSet?.item || []
        d2 = d2.value.DescribeImagesResponse.imagesSet?.item || []
        self.onFetch( d1.concat(d2) )
      , ( r1, r2 )->
        d1 = r1.value.DescribeImagesResponse.imagesSet?.item if r1.state is "fulfilled"
        d2 = r2.value.DescribeImagesResponse.imagesSet?.item if r2.state is "fulfilled"
        if d1 || d2
          self.onFetch( [].concat(d1||[], d2||[]) )

        throw d1 if d1.state is "rejected"
        throw d2 if d2.state is "rejected"

    onFetch : ( amiArray )->
      @__models = fixDescribeImages( amiArray )
      CloudResources( constant.RESTYPE.AMI, @region() ).add amiArray
      return

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      savedAmis = []
      amiIds  = []
      for ami in data
        try
          ami.id = ami.imageId
          delete ami.imageId
          savedAmis.push ami
          amiIds.push ami.id
        catch e

      CloudResources( constant.RESTYPE.AMI, @region() ).add savedAmis
      @__models = amiIds
      return
  }




  ### This Collection is used to fetch favorite ami ###
  SpecificAmiCollection.extend {
    ### env:dev ###
    ClassName : "CrFavAmiCollection"
    ### env:dev:end ###

    type  : "FavoriteAmi"

    doFetch : ()->
      ApiRequest("favorite_info", {
        region_name : @region()
        provider    : "AWS"
        service     : "EC2"
        resource    : "AMI"
      })

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      savedAmis = []
      favAmiId  = []
      for ami in data
        try
          item = JSON.parse(ami.amiVO)
          item.id = ami.id
          savedAmis.push item
          favAmiId.push ami.id
        catch e

      CloudResources( constant.RESTYPE.AMI, @region() ).add savedAmis
      @__models = favAmiId
      return

    unfav : ( id )->
      self = @
      idx = @__models.indexOf id
      if idx is -1
        d = Q.defer()
        d.resolve()
        return d.promise

      ApiRequest("favorite_remove", {
        resource_ids : [id]
      }).then ()->
        idx = self.__models.indexOf amiId
        self.__models.splice idx, 1
        self.trigger "update"
        self

    fav : ( ami )->
      if _.isString( ami )
        imageId = ami
        ami = ""
      else
        ami = $.extend {}, ami
        imageId = ami.id

      self = @
      ApiRequest("favorite_add", {
        resource : { id: imageId, provider: 'AWS', 'resource': 'AMI', service: 'EC2' }
      }).then ()->
        self.__models.push imageId

        if ami
          CloudResources( constant.RESTYPE.AMI, self.region() ).add ami, {add: true, merge: true, remove: false}

        self.trigger "update"
        self
  }
