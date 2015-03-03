
###
----------------------------
  The Model for application
----------------------------

  ApplicationModel holds the data / settings of VisualOps. It also provides some convenient methods.

###

define [
  "OpsModel"
  "./submodels/Notification"
  "Project"
  "ApiRequest"
  "ApiRequestOs"
  "ThumbnailUtil"
  "constant"
  "i18n!/nls/lang.js"
  "backbone"
], ( OpsModel, Notifications, Project, ApiRequest, ApiRequestOs, ThumbnailUtil, constant, lang )->


  Backbone.Model.extend {

    # AppData Related.
    getPriceData : ( awsRegion )-> (@__awsdata[ awsRegion ] || {}).price
    getOsFamilyConfig : ( awsRegion )-> (@__awsdata[ awsRegion ] || {}).osFamilyConfig
    getInstanceTypeConfig : ( awsRegion )-> (@__awsdata[ awsRegion ] || {}).instanceTypeConfig
    getRdsData: ( awsRegion ) -> (@__awsdata[ awsRegion ] || {}).rds
    getStateModule : ( repo, tag )-> @__stateModuleData[ repo + ":" + tag ]

    getOpenstackFlavors : ( provider, region )-> @__osdata[ provider ][ region ].flavors
    getOpenstackQuotas  : ( provider )-> @__osdata[ provider ].quota


    notifications : ()-> @get("notifications")


    # User Related.
    # Returns a promise that will fulfilled when the user data is available.
    fetchUserData : ( userCodeList )->
      toFetch = []
      result  = {}
      for usercode in userCodeList
        userdata = @__vousercache[usercode]
        if userdata is undefined
          toFetch.push usercode
        else if userdata
          result[usercode] = $.extend {}, userdata

      if not toFetch.length
        d = Q.defer()
        d.resolve( result )
        return d.promise

      self = @
      ApiRequest("account_list_user",{user_list:toFetch}).then (res)->
        self.__vousercache[usercode] = false for usercode in toFetch
        for d in res
          data = self.__vousercache[d.username] = {
            usercode : d.username
            email    : Base64.decode( d.email || "" )
          }
          data.avatar = "https://www.gravatar.com/avatar/" + CryptoJS.MD5(data.email.trim().toLowerCase()).toString()
          result[d.username] = $.extend {}, data
        result

    # Project Related.
    getOpsModelById : ( opsModelId )->
      for p in @get("projects").models
        ops = p.getOpsModel( opsModelId )
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
      notifications : new Notifications()
      projects : new (Backbone.Collection.extend({
        comparator : ( m )-> if m.isPrivate() then "" else m.get("name")
        initialize : ()-> @on "change:name", @sort, @; return
      }))()

    initialize : ()->
      @__awsdata = {}
      @__osdata  = {}
      @__stateModuleData = {}
      @__vousercache = {}

      self = @
      # Watch request changes
      App.WS.collection.request.find().observe {
        added   : (req)-> self.__handleRequest(req)
        changed : (req)-> self.__handleRequest(req)
      }
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

    __handleRequest : ( req )->
      if not req.project_id then return
      if req.state is constant.OPS_STATE.PENDING then return

      # Ignore applying diff & import request
      if req.code is constant.OPS_CODE_NAME.APP_SAVE or req.code is constant.OPS_CODE_NAME.APP_IMPORT then return

      targetId = if req.dag and req.dag.spec then req.dag.spec.id else req.rid

      app = @projects().get( req.project_id )?.apps().get( targetId ) || @notifications().get( targetId )
      if not app or not app.id then return
      # Only create notification for app that have id.

      n = @notifications().get( app.id )
      if n
        n.updateWithRequest(req)
      else if req.username is App.user.get("usercode")
        # Only create new notification if the app is updating by the current user.
        n = @notifications().add(app, req)

      # Mark the notification as read if the websocket is not ready.
      if not App.WS.isSubReady( req.project_id, "request" )
        n.markAsOld()
      return
  }
