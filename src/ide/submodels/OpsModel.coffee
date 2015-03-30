
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["ApiRequest", "constant", "CloudResources", "ThumbnailUtil", "backbone"], ( ApiRequest, constant, CloudResources, ThumbUtil )->

  KnownOpsModelClass = {}

  OpsModelType =
    OpenStack : "OpenstackOps"
    Amazon    : "AwsOps"
    Mesos     : "Mesos"

  OpsModelState =
    UnRun        : 0
    Running      : 1
    Stopped      : 2
    Initializing : 3
    Starting     : 4
    Updating     : 5
    Stopping     : 6
    Terminating  : 7
    Destroyed    : 8 # When OpsModel changes to this State, it doesn't trigger "change:state" event, instead, it triggers "destroy" event and its collection will trigger "update" event.
    Saving       : 9
    RollingBack  : 10 # When OpsModel fails to run (Initializing), it will transition to this state before going to `Destroyed`
    Removing     : 11 # When we directly remove the app from server, it will transition to this state before going to `Destroyed`

  OpsModelStateDesc = ["", "Running", "Stopped", "Starting", "Starting", "Updating", "Stopping", "Terminating", "", "Saving", "RollingBack", "Removing"]

  OpsModelLastestVersion = "2014-11-11"

  OpsModel = Backbone.Model.extend {

    type : "GenericOps"

    defaults : ()->
      updateTime  : +(new Date())
      state       : OpsModelState.UnRun
      version     : OpsModelLastestVersion

      name        : ""
      provider    : ""
      region      : ""
      description : ""
      usage       : ""        # An attr bound to app

      unlimited   : false     # Indicate if this is an app launch before 2014-11-11
      importMsrId : undefined # If the ops is imported, this should hold an id of the resource.
      stoppable   : true      # False, if the app has instance_store_ami. Use only in aws

      requestId      : ""     # When the app is launching, this holds the request id.
      progress       : 0      # The progress of current action on the app.
      opsActionError : ""     # The failure of the lastest action.

      # duplicateTarget : ""  # Use internally.


    constructor : ( attr, opts )->
      attr = attr || {}
      opts = opts || {}

      if this.type is "GenericOps"
        if opts.jsonData
          provider = opts.jsonData.provider

        attr.provider = provider || attr.provider || "aws::global" # Set default provider

        console.assert( KnownOpsModelClass[attr.provider], "Cannot find specific OpsModel for provider '#{attr.provider}'" )

        Model = KnownOpsModelClass[ attr.provider ]
        if Model
          return new Model( attr, opts )

      Backbone.Model.apply this, arguments

    initialize : ( attr, options )->

      @__setJsonType( options || {})

      if options and options.jsonData
        @__setJsonData options.jsonData

      @__userTriggerAppProgress = false

      ### env:dev ###
      @listenTo @, "change:state", ()-> console.log "OpsModel's state changed", [@project()?.get("name"), @get("name"), OpsModelStateDesc[ @get("state") ], @, MC.prettyStackTrace()]
      ### env:dev:end ###
      ### env:debug ###
      @listenTo @, "change:state", ()-> console.log "OpsModel's state changed", [@project()?.get("name"), @get("name"), OpsModelStateDesc[ @get("state") ], @, MC.prettyStackTrace()]
      ### env:debug:end ###
      return

    # Returns the project to which this opsmodel belongs.
    project : ()->
      for p in App.model.projects().models
        ops = p.stacks().get( @ ) or p.apps().get( @ )
        if ops then return p
      return null

    url : ()->
      p = @project() || ""
      if p then p = p.url()
      p + "/" + @relativeUrl()

    relativeUrl : ()->
      if @get("id")
        "ops/#{@get('id')}"
      else
        "unsaved/#{@cid}"

    # Returns a credential of a project that is capable of handling this opsmodel
    credential   : ()-> @project().credOfProvider( @get("provider") )
    credentialId : ()-> (@credential() || {}).id

    isStack    : ()->
      if @attributes.state is OpsModelState.UnRun
        return true
      if @attributes.state is OpsModelState.Saving
        return (@get("id")||"").indexOf("app-") is -1
      false

    isApp      : ()-> !@isStack()
    isImported : ()-> !!@attributes.importMsrId

    # Payment restricted
    isPMRestricted : ()-> @isApp() and !@get("unlimited")

    testState    : ( state )-> @attributes.state is state
    getStateDesc : ()-> OpsModelStateDesc[ @attributes.state ]

    # Returns a plain object to represent this model.
    # If you want to access the JSON of the stack/app, use getJsonData() instead.
    toJSON : ( options )->
      o = Backbone.Model.prototype.toJSON.call( this )
      o.stateDesc  = OpsModelStateDesc[ o.state ]
      o.regionName = constant.REGION_SHORT_LABEL[ o.region ]
      o.url        = @url()
      if @isProcessing() then o.progressing = true

      if options and options.thumbnail
        o.thumbnail = ThumbUtil.fetch(o.id)
      o

    # Return true if the stack is saved in the server.
    isPersisted : ()-> !!@get("id")
    # Return true if the stack/app should be show to the user.
    isExisting : ()->
      state = @get("state")
      if state is OpsModelState.Destroyed
        console.warn "There's probably a bug existing that the destroyed opsmodel is still be using by someone."

      !!(@get("id") && state isnt OpsModelState.Destroyed)

    # Get the Most Significant Resource id.
    getMsrId : ()-> @get("importMsrId") || undefined

    # Hardcode for demo
    getMarathonStackId: -> 'stack-334a97bd'

    getThumbnail  : ()-> ThumbUtil.fetch(@get("id"))
    saveThumbnail : ( thumb )->
      if thumb
        ThumbUtil.save( @get("id"), thumb )
        @trigger "change"
      else
        ThumbUtil.save( @get("id"), "" )
      return

    # Use this method to access the real json of the opsModel
    getJsonData : ()->
      base = {
        id          : @get("id") or ""
        name        : @get("name")
        region      : @get("region")
        usage       : @get("usage")
        provider    : @get("provider")
        version     : @get("version")
        time_update : @get("updateTime")
        description : @get("description")
        property    : { stoppable : @get("stoppable") }
      }
      if @__jsonData
        _.extend(base, {
          resource_diff : @__jsonData.resource_diff
          component     : @__jsonData.component
          layout        : @__jsonData.layout
          agent         : @__jsonData.agent
          stack_id      : @__jsonData.stack_id
          host          : @__jsonData.host
          type          : @__jsonData.type
        })

    # Use this method to load the newest json.
    # Returns a promise that will be fulfilled when the json is loaded.
    # After that, use getJsonData() to retreive the json.
    fetchJsonData : ()-> @__fjdImport( @ ) || @__fdjLocalInit( @ ) || @__fjdStack( @ ) || @__fjdApp( @ )

    __fdjLocalInit : ()->
      # Always load the json from server if the ops has been saved to server.
      if @isPersisted() then return

      if @get("__________itsshitdontsave")
        d = Q.defer()
        d.resolve @
        return d.promise

      if @get("duplicateTarget")
        # The stack is duplication from other stack.
        self = @
        return ApiRequest("stack_save_as",{
          region_name : @get("region")
          stack_id    : @get("duplicateTarget")
          new_name    : @collection.getNewName()
        }).then ( json )->
          self.__setJsonData( json )
          self.set {
            id : json.id
            duplicateTarget : undefined
          }

      if not @__jsonData
        @__setJsonData( @__defaultJson() )

      @save()

    __fjdImport : ( self )->
      if not @isImported() then return

      CloudResources( @credentialId(), "OpsResource", @getMsrId() ).init({
        region   : @get("region")
        project  : @project().id
        provider : @get("provider")
      }).fetchForceDedup().then ()->
        self.__setJsonData self.generateJsonFromRes()

    generateJsonFromRes : ()->
      json = CloudResources( @credentialId(), 'OpsResource', @getMsrId() ).generatedJson

      if not json.agent.module.repo
        json.agent.module =
          repo : App.user.get("repo")
          tag  : App.user.get("tag")
      json

    __fjdStack : ( self )->
      if not @isStack() then return
      ApiRequest("stack_info", {
        key_id      : @credentialId()
        region_name : @get("region")
        stack_ids   : [@get("id")]
      }).then (ds)-> self.__setJsonData( ds[0] )

    __fjdApp : ( self )->
      if not @isApp() then return
      ApiRequest("app_info", {
        key_id      : @credentialId()
        region_name : @get("region")
        app_ids     : [@get("id")]
      }).then (ds)-> self.__setJsonData( ds[0] )

    __setJsonData : ( json )->

      if not json
        @__destroy()
        throw new McError( ApiRequest.Errors.MissingDataInServer, "Stack/App doesn't exist." )

      if not json.agent
        json.agent = { enabled : false }

      if not json.agent.module or not json.agent.module.repo
        json.agent.module = {
          repo : App.user.get("repo")
          tag  : App.user.get("tag")
        }

      if json.type then @__setJsonType(json)

      if not json.property
        json.property = { stoppable : true }

      ###
      Old JSON will have structure like :
      layout : {
        component : { node : {}, group : {} }
        size : []
      }
      New JSON will have structure like :
      layout : {
        xxx  : {}
        size : []
      }
      ###
      if json.layout
        if json.layout.component
          newLayout      = $.extend {}, json.layout.component.node, json.layout.component.group
          newLayout.size = json.layout.size
          json.layout    = newLayout

        if not json.layout.size
          json.layout.size = [240, 240]

      # Normalize stack version in case some old stack is not using date as the version
      # The version will be updated after serialize
      if (json.version or "").split("-").length < 3 then json.version = OpsModelLastestVersion

      @__jsonData = {
        resource_diff : json.resource_diff
        component     : json.component
        layout        : json.layout
        agent         : json.agent
        host          : json.host
        type          : @__jsonType
      }

      @__jsonFramework = null
      if json.component
        _.each json.component, (comp)->
          if comp.type in [constant.RESTYPE.INSTANCE, constant.RESTYPE.LC] and comp.state?.length
            _.each comp.state, (state)->
              if state.module in ["linux.mesos.slave", "linux.mesos.master"] and state.parameter.framework?.length
                @__jsonFramework = state.parameter.framework

      stoppable = json.property?.stoppable or true

      @set {
        name        : json.name     || @get("name")
        version     : json.version  || OpsModelLastestVersion
        stoppable   : stoppable
        description : json.description
        usage       : json.usage
        updateTime  : json.time_update
      }

      @

    __setJsonType: (opts = {})->
      @__jsonType = opts.type || "aws"
      @__jsonFramework = opts.framework || null
      return

    getJsonType: ()-> @__jsonType
    getJsonFramework : ()-> @__jsonFramework
    isMesos: ()-> @getJsonType() is "mesos"

    # Save the stack in server, returns a promise
    save : ( newJson, thumbnail )->
      if @isApp() or @testState( OpsModelState.Saving ) then return @__returnErrorPromise()

      newJson = newJson or @getJsonData()
      # Ensure the json's id is opsmodel's id.
      newJson.id = @get("id")

      # Check if the name has been used.
      nameClash = @collection.where({name:newJson.name}) || []
      if nameClash.length > 1 or (nameClash[0] and nameClash[0] isnt @)
        d = Q.defer()
        d.reject(McError( ApiRequest.Errors.StackRepeatedStack, "Stack name has already been used." ))
        return d.promise

      # Apply changes via api.
      @set "state", OpsModelState.Saving
      self = @
      ApiRequest( (if @isPersisted() then "stack_save" else "stack_create"), {
        region_name : @get("region")
        spec        : newJson
        key_id      : @credentialId()
      }).then ( res )->
        # After we save the stack, we use the saved json to update the opsmodel's attributes.
        self.__setJsonData( res )

        self.set {
          state : OpsModelState.UnRun
          id    : res.id  # if opsmodel's id is not empty, it should be equal to res.id
        }

        ThumbUtil.save( res.id, thumbnail )

        self.trigger "jsonDataSaved", self
        self

      , ( err )->
        self.set "state", OpsModelState.UnRun
        throw err

    # Delete the stack in server, returns a promise
    remove : ()->
      if @isPersisted() and @isApp() then return @__returnErrorPromise()

      self = @
      collection = @collection

      @__userTriggerAppProgress = true
      @__destroy()

      if not @isPersisted()
        d = Q.defer()
        d.resolve()
        return d.promise

      ApiRequest("stack_remove",{
        region_name : @get("region")
        stack_id    : @get("id")
      }).fail ( e )->
        if e.error is ApiRequest.Errors.StackInvalidId
          # The stack is not found in the server. We simply ignore this error
          # so that the stack will be remove in local.
          return

        self.__userTriggerAppProgress = false
        self.set "state", OpsModelState.UnRun
        # If we cannot delete the stack, we just add it back to the stackList.
        collection.add self

    # Runs a stack into app, returns a promise that will fullfiled with a new OpsModel.
    run : ( toRunJson, appName )->
      # Ensure the json has correct id.
      toRunJson.id = ""
      toRunJson.stack_id = @get("id")

      project = @project()
      ApiRequest("stack_run",{
        region_name : toRunJson.region
        stack       : toRunJson
        app_name    : appName
        key_id      : @credentialId()
      }).then ( res )->
        project.apps().add new OpsModel({
          name       : appName
          requestId  : res[0]
          state      : OpsModelState.Initializing
          region     : toRunJson.region
          provider   : toRunJson.provider
          usage      : toRunJson.usage
          updateTime : +(new Date())
        })

    # Duplicate the stack
    duplicate : ()->
      if @isApp() then return

      @collection.add new OpsModel({
        duplicateTarget : @get("id")
        provider        : @get("provider")
        region          : @get("region")
      })

    # Stop the app, returns a promise
    stop : ()->
      if not @isApp() or @get("state") isnt OpsModelState.Running then return @__returnErrorPromise()

      self = @
      @attributes.progress = 0
      @set "state", OpsModelState.Stopping
      @__userTriggerAppProgress = true

      ApiRequest("app_stop",{
        region_name : @get("region")
        key_id      : @credentialId()
        app_id      : @get("id")
        app_name    : @get("name")
      }).fail ( err )->
        self.__userTriggerAppProgress = false
        self.set "state", OpsModelState.Running
        throw err

    start : ()->
      if not @isApp() or @get("state") isnt OpsModelState.Stopped then return @__returnErrorPromise()

      self = @
      @attributes.progress = 0
      @set "state", OpsModelState.Starting
      @__userTriggerAppProgress = true

      ApiRequest("app_start",{
        region_name : @get("region")
        key_id      : @credentialId()
        app_id      : @get("id")
        app_name    : @get("name")
      }).fail ( err )->
        self.__userTriggerAppProgress = false
        self.set "state", OpsModelState.Stopped
        throw err

    # Terminate the app, returns a promise
    terminate : ( force = false , extraOption )->
      if not @isApp() then return @__returnErrorPromise()

      if @get("state") isnt OpsModelState.Stopped and @get("state") isnt OpsModelState.Running then return @__returnErrorPromise()

      self = @
      oldState = @get("state")
      @attributes.progress = 0
      @set("state", if force then OpsModelState.Removing else OpsModelState.Terminating)
      @__userTriggerAppProgress = true

      options = $.extend {
        region_name     : @get("region")
        app_id          : @get("id")
        app_name        : @get("name")
        flag            : force
        key_id          : @credentialId()
      }, ( extraOption || {} )

      ApiRequest("app_terminate", options).then ()->
        # Force Termination will immediately returns sucess / failure.
        # Normal Termination will returns its status by Websockt.
        if force then self.__destroy()
        return
      , ( err )->
        self.__userTriggerAppProgress = false
        self.set "state", oldState
        throw err

    # Update the app, returns a promise
    update : ( newJson, fastUpdate )->
      if not @isApp() then return @__returnErrorPromise()

      if @get("state") isnt OpsModelState.Stopped and @get("state") isnt OpsModelState.Running then return @__returnErrorPromise()

      if @testState( OpsModelState.Updating )
        console.error "The app is already updating!"
        if @__updateAppDefer
          return @__updateAppDefer.promise
        else
          return @__returnErrorPromise()

      oldState = @get("state")
      @attributes.progress = 0
      @__userTriggerAppProgress = true
      @set("state", OpsModelState.Updating)

      @__updateAppDefer = Q.defer()

      self = @

      # Send Request
      ApiRequest("app_update", {
        region_name : @get("region")
        spec        : newJson
        app_id      : @get("id")
        fast_update : fastUpdate
        key_id      : @credentialId()
      }).fail ( error )->
        self.__userTriggerAppProgress = false
        self.__updateAppDefer.reject( error )

      errorHandler = ( error )->
        self.__updateAppDefer = null
        self.attributes.progress = 0
        self.set { state : oldState }
        throw error

      # The real promise
      @__updateAppDefer.promise.then ()->

        self.fetchJsonData().then ()->
          # The importMsrId should be undefined when the update() is called.
          # Not sure what this line does. Maybe there's some kind of bug out there.
          self.importMsrId = undefined # Mark as not imported once we've finish saving.

          self.__updateAppDefer = null
          self.set "state", OpsModelState.Running

        , errorHandler

      , errorHandler

    importApp : ( newJson )->
      newJson.id = ""
      @syncAppJson( newJson )

    # Directly modify the data in mongo. Can be used to import app or update the app's json.
    saveApp : ( newJson )->
      newJson.id = @get("id")
      @syncAppJson( newJson )

    # This method doesn't trigger an app update.
    syncAppJson : ( newJson )->
      if not @isApp() or ( @get("state") isnt OpsModelState.Stopped and @get("state") isnt OpsModelState.Running ) then return @__returnErrorPromise()

      if @testState( OpsModelState.Saving )
        console.error "The app is already saving!"
        if @__saveAppDefer
          return @__saveAppDefer.promise
        else
          return @__returnErrorPromise()

      # save the name to the imported app first
      if not newJson.id then @set "name", newJson.name

      oldState = @get("state")
      @attributes.progress = 0
      @__userTriggerAppProgress = true
      @set("state", OpsModelState.Saving)

      @__saveAppDefer = Q.defer()

      self = @

      newJson.time_update = @get("updateTime")

      # Send Request
      ApiRequest("app_save_info", {spec:newJson, key_id: self.credentialId()}).then (res)->
        if not self.id
          self.attributes.requestId = res[0]

        self.attributes.importMsrId = undefined
        newJson.time_update = res[3]
        return
      , ( error )->
        self.__userTriggerAppProgress = false
        self.__saveAppDefer.reject( error )

      # The real promise
      @__saveAppDefer.promise.then ()->
        self.__setJsonData( newJson )

        self.__saveAppDefer       = null
        self.attributes.requestId = undefined
        self.attributes.progress  = 0

        self.set "state", oldState
        return
      , ( error )->
        self.__saveAppDefer       = null
        self.attributes.requestId = undefined
        self.attributes.progress  = 0

        self.set "state", oldState
        throw error

    isProcessing : ()->
      state = @attributes.state
      state is OpsModelState.Initializing || state is OpsModelState.Stopping || state is OpsModelState.Updating || state is OpsModelState.Terminating || state is OpsModelState.Starting || state is OpsModelState.Saving || state is OpsModelState.RollingBack || state is OpsModelState.Removing

    isLastActionTriggerByUser : ()-> @__userTriggerAppProgress

    updateWithWSEvent : ( wsRequest )->
      # 1. Processing
      if wsRequest.state is constant.OPS_STATE.INPROCESS and @isProcessing()
        step       = 0
        totalSteps = 1
        if wsRequest.dag and wsRequest.dag.step
          totalSteps = wsRequest.dag.step.length
          for i in wsRequest.dag.step
            if i[1] is "done" then ++step

          # Special treatment for failing to do a request.
          if wsRequest.dag.state is "Rollback"
            @set "state", OpsModelState.RollingBack

        progress = parseInt( step * 100.0 / totalSteps )
        if @attributes.progress != progress
          # Disable Backbone's auto triggering change event. Because I don't wan't that changing progress will trigger `change:progress` and `change`
          @attributes.progress = progress
          @trigger "change:progress", @, progress

        return

      # 2. Starting / Completed / Failed
      console.info "OpsModel's state changes due to WS event:", [@project()?.get("name"), @get("name"), @, wsRequest]
      if wsRequest.state is constant.OPS_STATE.INPROCESS
        toStateIndex = 0
      else if wsRequest.state is constant.OPS_STATE.DONE
        toStateIndex = 1
      else
        toStateIndex = 2

      OMS = OpsModelState

      switch wsRequest.code
        when constant.OPS_CODE_NAME.LAUNCH
          toState = [ OMS.Initializing, OMS.Running, OMS.Destroyed ]
        when constant.OPS_CODE_NAME.STOP
          toState = [ OMS.Stopping, OMS.Stopped, OMS.Running ]
        when constant.OPS_CODE_NAME.START
          toState = [ OMS.Starting, OMS.Running, OMS.Stopped ]
        when constant.OPS_CODE_NAME.TERMINATE
          toState = [ OMS.Terminating, OMS.Destroyed, OMS.Stopped ]
        when constant.OPS_CODE_NAME.UPDATE, constant.OPS_CODE_NAME.STATE_UPDATE
          if @__updateAppDefer
            if toStateIndex is 1
              @__updateAppDefer.resolve()
              return
            if toStateIndex is 2
              @__updateAppDefer.reject McError( ApiRequest.Errors.OperationFailure, wsRequest.data )
              return

          toState = [ OMS.Updating, OMS.Running, OMS.Stopped ]

        when constant.OPS_CODE_NAME.APP_SAVE, constant.OPS_CODE_NAME.APP_IMPORT # This is saving app.
          if @__saveAppDefer
            if toStateIndex is 1
              @__saveAppDefer.resolve()
              return
            if toStateIndex is 2
              @__saveAppDefer.reject McError( ApiRequest.Errors.OperationFailure, wsRequest.data )
              return

          toState = [ OMS.Saving, OMS.Running, OMS.Stopped ]

      toState = toState[ toStateIndex ]
      # 3. Clear the useraction flag if the state changes from DONE state to another state.
      if not @isProcessing() and @get("state") isnt toState
        @__userTriggerAppProgress = false

      # 4. Log message if failed.
      @attributes.opsActionError = if toStateIndex is 2 then wsRequest.data else ""

      # 5. Transition to other state.
      if toState is OpsModelState.Destroyed
        @__destroy()
      else if toState
        @set {
          state    : toState
          progress : 0
        }
      return

    ###
     Internal Methods
    ###
    # Overriden model methods so that user won't call it acidentally
    destroy : ()->
      console.info "OpsModel's destroy() doesn't do anything. You probably want to call remove(), stop() or terminate()"

    __destroy : ()->
      if @attributes.state is OpsModelState.Destroyed
        return

      # Remove thumbnail
      ThumbUtil.remove( @get("id") )

      # Cleanup CloudResources if we are an app
      msrId = @getMsrId()
      if msrId then CloudResources( @credential(), "OpsResource", msrId ).destroy()

      # Directly modify the attr to avoid sending an event, because destroy would trigger an update event
      @attributes.state = OpsModelState.Destroyed
      @trigger 'destroy', @, @collection

    __returnErrorPromise : ()->
      d = Q.defer()
      d.resolve McError( ApiRequest.Errors.InvalidMethodCall, "Currently, the specific action can not be performed on the stack/app." )
      d.promise

    # This method init a json for a newly created stack.
    __defaultJson : ()->
      resource_diff : true
      component     : {}
      layout        : { size : [240, 240] }
      agent         :
        enabled : true
        module  :
          repo : App.user.get("repo")
          tag  : App.user.get("tag")

  }, {
    extend : ( protoProps, staticProps ) ->

      # Create subclass
      subClass = (window.__detailExtend || Backbone.Model.extend).call( this, protoProps, staticProps )

      for provider in staticProps.supportedProviders
        KnownOpsModelClass[ provider ] = subClass

      subClass
  }

  OpsModel.Type  = OpsModelType
  OpsModel.State = OpsModelState
  OpsModel.LatestVersion = OpsModelLastestVersion

  OpsModel
