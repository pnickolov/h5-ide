
###
----------------------------
  The Model for application
----------------------------

  ApplicationModel holds the data / settings of VisualOps. It also provides some convenient methods.

###

define [
  "OpsModel"
  "Project"
  "ApiRequest"
  "ApiRequestOs"
  "ThumbnailUtil"
  "constant"
  "i18n!/nls/lang.js"
  "backbone"
], ( OpsModel, Project, ApiRequest, ApiRequestOs, ThumbnailUtil, constant, lang )->

  Backbone.Model.extend {

    # AppData Related.
    getPriceData : ( awsRegion )-> (@__awsdata[ awsRegion ] || {}).price
    getOsFamilyConfig : ( awsRegion )-> (@__awsdata[ awsRegion ] || {}).osFamilyConfig
    getInstanceTypeConfig : ( awsRegion )-> (@__awsdata[ awsRegion ] || {}).instanceTypeConfig
    getRdsData: ( awsRegion ) -> (@__awsdata[ awsRegion ] || {}).rds
    getStateModule : ( repo, tag )-> @__stateModuleData[ repo + ":" + tag ]

    getOpenstackFlavors : ( provider, region )-> @__osdata[ provider ][ region ].flavors
    getOpenstackQuotas  : ( provider )-> @__osdata[ provider ].quota


    # Project Related.
    getOpsModelById : ( opsModelId )->
      for p in @get("projects").models
        ops = p.getOpsMOdel( opsModelId )
        if ops then return ops
      return null

    projects : ()-> @get("projects")
    getPrivateProject : ()->
      for p in @get("projects").models
        if p.isPrivate() then return p
      null

    # Create a new project. It returns a promise.
    # The promise will be fulfilled when the project is created successfully with the new project as the fulfillment.
    # attr : {
    #   name       : ""
    #   firstname  : ""
    #   lastname   : ""
    #   email      : ""
    #   card       : {
    #      number : ""
    #      expire : ""
    #      cvv    : ""
    #   }
    # }
    #
    createProject : ( attr )->
      self = @

      ApiRequest( "project_create", {
        project_name : attr.name
        first_name   : attr.firstname
        last_name    : attr.lastname
        email        : attr.email
        credit_card  : {
          full_number      : attr.card.number
          expiration_month : attr.card.expire.split("/")[0] or ""
          expiration_year  : attr.card.expire.split("/")[1] or ""
          cvv              : attr.card.cvv
        }
      }).then ( projectObj )->
        p = new Project( projectObj )
        self.projects().add(p)
        p


    ###
      Internal methods
    ###
    defaults : ()->
      projects : new (Backbone.Collection.extend({
        comparator : ( m )-> if m.isPrivate() then "" else m.get("name")
        initialize : ()-> @on "change:name", @sort, @; return
      }))()

    initialize : ()->
      @__awsdata = {}
      @__osdata  = {}
      @__stateModuleData = {}
      return

    # Fetches user's stacks and apps from the server, returns a promise
    fetch : ()->
      self = this
      # Load user's projects.
      projectlist = ApiRequest("project_list").then (res)-> self.__parseProjectData( res )

      # Load Application Data.
      awsData = ApiRequest("aws_aws",{fields : ["region","price","instance_types","rds"]}).then ( res )-> self.__parseAwsData( res )

      # The api is deprecated, might update in the future.
      # osData  = ApiRequestOs("os_os",   {provider:null}).then (res)-> self.__parseOsData( res )

      Q.all([ projectlist, awsData ]).then ()->
        # Cleans up unused thumbnails.
        ids = []
        for p in self.projects().models
          ids = ids.concat p.stacks().pluck("id"), p.apps().pluck("id")

        ThumbnailUtil.cleanup( ids )
        return

    __parseProjectData : ( res )->
      for p in res || []
        @attributes.projects.add( new Project( p ) )
      return

    __parseAwsData : ( res )->
      for i in res
        instanceTypeConfig = {}

        @__awsdata[ i.region ] = {
          price              : i.price
          osFamilyConfig     : i.instance_types.sort
          instanceTypeConfig : instanceTypeConfig
          rds                : i.rds
        }

        # Format instance type info.
        for typeInfo in i.instance_types.info || []
          if not typeInfo then continue
          cpu = typeInfo.cpu || {}
          typeInfo.name = typeInfo.description

          typeInfo.formated_desc = [
            typeInfo.name || ""
            cpu.units + " ECUs"
            cpu.cores + " vCPUs"
            typeInfo.memory + " GiB memory"
          ]
          typeInfo.description = typeInfo.formated_desc.join(", ")

          storage = typeInfo.storage
          if storage and storage.ssd is true
            typeInfo.description += ", #{storage.count} x #{storage.size} GiB SSD Storage Capacity"

          instanceTypeConfig[ typeInfo.typeName ] = typeInfo

      return

    __parseOsData : ( res )->
      self = this
      for provider, dataset of res
        for data in dataset
          providerData = @__osdata[ provider ] || (@__osdata[ provider ]={})
          providerData[ data.region ] =
            flavors : new Backbone.Collection( _.values(data.flavor) )

        #quota is user-related, need optimized when backend support multiple provider indeed
        # osQuota = ApiRequestOs("os_quota",{provider:provider}).then (res)-> self.__parseOsQuota( res )

      return

    __parseOsQuota : ( res )->
      quota = {}
      for provider, dataset of res
        for cate, data of dataset
          for key, q of data
            quota[ "#{cate}::#{key}" ] = q

        pd = @__osdata[ provider ] || (@__osdata[ provider ]={})
        pd.quota = quota
      return

    fetchStateModule : ( repo, tag )->
      data = @getStateModule( repo, tag )
      if data
        d = Q.defer()
        d.resolve( data )
        return d.promise

      self = @
      ApiRequest("state_module", {
        mod_repo : repo
        mod_tag  : tag
      }).then ( d )->
        try
          d = JSON.parse( d )
        catch e
          throw McError( ApiRequest.Errors.InvalidRpcReturn, "Can't load state data. Please retry." )
        self.__stateModuleData[ repo + ":" + tag ] = d
        d
  }
