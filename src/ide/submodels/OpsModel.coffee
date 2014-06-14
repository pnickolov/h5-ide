
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["ApiRequest", "constant", "CloudResources", "component/exporter/Thumbnail", "backbone"], ( ApiRequest, constant, CloudResources, ThumbUtil )->

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

  OpsModelStateDesc = ["", "Running", "Stopped", "Starting", "Starting", "Updating", "Stopping", "Terminating", ""]

  OpsModel = Backbone.Model.extend {

    defaults : ()->
      updateTime     : +(new Date())
      region         : ""
      state          : OpsModelState.UnRun
      stoppable      : true # If the app has instance_store_ami, stoppable is false
      # usage          : ""
      # terminateFail  : false
      # progress       : 0
      # opsActionError : ""
      # importVpcId    : ""
      # requestId      : ""

    initialize : ( attr, options )->
      if options
        if options.initJsonData
          @__initJsonData()
        if options.jsonData
          @__jsonData = options.jsonData
      return


    isStack    : ()-> @attributes.state is   OpsModelState.UnRun
    isApp      : ()-> @attributes.state isnt OpsModelState.UnRun
    isImported : ()-> !!@attributes.importVpcId

    testState : ( state )-> @attributes.state is state

    # Returns a plain object to represent this model.
    # If you want to access the JSON of the stack/app, use getJsonData() instead.
    toJSON : ( options )->
      o = Backbone.Model.prototype.toJSON.call( this )
      o.stateDesc  = OpsModelStateDesc[ o.state ]
      o.regionName = constant.REGION_SHORT_LABEL[ o.region ]
      if @isProcessing() then o.progressing = true

      if options
        if options.thumbnail
          o.thumbnail = ThumbUtil.fetch(o.id)
      o

    # Return true if the stack is saved in the server.
    isPresisted : ()-> !!@get("id")
    # Return true if the stack/app should be show to the user.
    isExisting : ()->
      state = @get("state")
      if state is OpsModelState.Destroyed
        console.warn "There's probably a bug existing that the destroyed opsmodel is still be using by someone."

      !!(@get("id") && state isnt OpsModelState.Destroyed)

    getVpcId : ()->
      if @get("importVpcId") then return @get("importVpcId")
      if not @__jsonData then return undefined
      for uid, comp of @__jsonData.component
        if comp.type is constant.RESTYPE.VPC
          return comp.resource.VpcId

      undefined

    getThumbnail  : ()-> ThumbUtil.fetch(@get("id"))
    saveThumbnail : ( thumb )->
      if thumb
        ThumbUtil.save( @get("id"), thumb )
        @trigger "change"
      return

    hasJsonData : ()-> !!@__jsonData
    getJsonData : ()-> @__jsonData
    fetchJsonData : ()->
      if @__jsonData
        d = Q.defer()
        d.resolve @
        return d.promise

      self = @
      if @isImported()
        return CloudResources( "OpsResource", @getVpcId() ).init( @get("region") ).fetch ()->
          json = self.generateJsonFromRes()
          self.__setJsonData json
          self

      else if @isStack()
        return ApiRequest("stack_info", {
          region_name : @get("region")
          stack_ids   : [@get("id")]
        }).then (ds)-> self.__setJsonData( ds[0] )
      else
        return ApiRequest("app_info", {
          region_name : @get("region")
          app_ids     : [@get("id")]
        }).then (ds)-> self.__setJsonData( ds[0] )

    __setJsonData : ( json )->

      if not json
        @__destroy()
        throw new McError( ApiRequest.Errors.MissingDataInServer, "Stack/App doesn't exist." )

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
      if json.layout and json.layout.component
        newLayout      = $.extend {}, json.layout.component.node, json.layout.component.group
        newLayout.size = json.layout.size
        json.layout    = newLayout

      # Normalize stack version in case some old stack is not using date as the version
      # The version will be updated after serialize
      if (json.version or "").split("-").length < 3 then json.version = "2013-09-13"

      @__jsonData = json
      @

    generateJsonFromRes : ()->
      res = CloudResources.getAllResourcesForVpc( @get("region"), @getVpcId(), @__jsonData )
      if @__jsonData
        c = @__jsonData.component
        l = @__jsonData.layout
        delete @__jsonData.component
        delete @__jsonData.layout
        json = $.extend true, {}, @__jsonData
        @__jsonData.component = c
        @__jsonData.layout = l
      else
        json = @__createRawJson()

      json.component = res.component
      json.layout    = res.layout

      json

    # Save the stack in server, returns a promise
    save : ( newJson, thumbnail )->
      if @isApp() and @__saving then return @__returnErrorPromise()
      @__saving = true

      nameClash = @collection.where({name:newJson.name}) || []
      if nameClash.length > 1 or nameClash[0] isnt @
        d = Q.promise()
        d.reject(McError( ApiRequest.Errors.StackRepeatedStack, "Stack name has already been used." ))
        return d.promise

      api = if @get("id") then "stack_save" else "stack_create"

      self = @
      ApiRequest(api, {
        region_name : @get("region")
        spec        : newJson
      }).then ( res )->

        attr = {
          name       : newJson.name
          updateTime : +(new Date())
          stoppable  : newJson.property.stoppable
        }

        if not self.get("id")
          attr.id    = res
          newJson.id = res # In newly created stack, the newJSON won't have id when saving.

        if thumbnail then ThumbUtil.save( self.id || attr.id, thumbnail )

        self.set attr
        self.__jsonData = newJson
        self.__saving   = false
        self.trigger "jsonDataSaved", self

        # The stack is a newly created stack. We would like to trigger "update" in the collection
        # So that other's can update their view.
        if attr.id then self.collection.__triggerUpdate self

        return self
      , ( err )->
        self.__saving = false
        throw err

    # Delete the stack in server, returns a promise
    remove : ()->
      if @isApp() then return @__returnErrorPromise()

      @__destroy()

      if not @get("id")
        d = Q.defer()
        d.resolve()
        return d.promise

      self = @
      ApiRequest("stack_remove",{
        region_name : @get("region")
        stack_id    : @get("id")
      }).fail ()->
        @set "state", OpsModelState.UnRun
        # If we cannot delete the stack, we just add it back to the stackList.
        App.model.stackList().add self

    # Runs a stack into app, returns a promise that will fullfiled with a new OpsModel.
    run : ( toRunJson, appName )->
      region = @get("region")
      ApiRequest("stack_run_v2",{
        region_name : region
        stack       : toRunJson
        app_name    : appName
      }).then ( res )->
        m = new OpsModel({
          name       : appName
          requestId  : res[0]
          state      : OpsModelState.Initializing
          progress   : 0
          region     : region
          usage      : toRunJson.usage
          updateTime : +(new Date())
          stoppable  : toRunJson.property.stoppable
        })
        App.model.appList().add m
        m

    # Duplicate the stack
    duplicate : ( name )->
      if @isApp() then return

      thumbnail  = ThumbUtil.fetch(@get("id"))
      attr       = $.extend true, {}, @attributes, {
        name       : name
        updateTime : +(new Date())
      }
      collection = @collection

      ApiRequest("stack_save_as",{
        region_name : @get("region")
        stack_id    : @get("id")
        new_name    : name || @collection.getNewName()
      }).then ( id )->
        if thumbnail then ThumbUtil.save id, thumbnail
        attr.id = id
        collection.add( new OpsModel(attr) )

    # Stop the app, returns a promise
    stop : ()->
      if not @isApp() or @get("state") isnt OpsModelState.Running then return @__returnErrorPromise()

      self = @
      @set "state", OpsModelState.Stopping
      @attributes.progress = 0
      ApiRequest("app_stop",{
        region_name : @get("region")
        app_id      : @get("id")
        app_name    : @get("name")
      }).fail ( err )->
        self.set "state", OpsModelState.Running
        throw err

    start : ()->
      if not @isApp() or @get("state") isnt OpsModelState.Stopped then return @__returnErrorPromise()
      self = @
      @set "state", OpsModelState.Starting
      @attributes.progress = 0
      ApiRequest("app_start",{
        region_name : @get("region")
        app_id      : @get("id")
        app_name    : @get("name")
      }).fail ( err )->
        self.set "state", OpsModelState.Stopped
        throw err

    # Terminate the app, returns a promise
    terminate : ( force = false )->
      if not @isApp() then return @__returnErrorPromise()
      oldState = @get("state")
      @set("state", OpsModelState.Terminating)
      @attributes.progress = 0
      @attributes.terminateFail = false
      self = @
      ApiRequest("app_terminate", {
        region_name : @get("region")
        app_id      : @get("id")
        app_name    : @get("name")
        flag        : force
      }).fail ( err )->
        if err.error < 0
          throw err

        self.set {
          state         : oldState
          terminateFail : true
        }
        throw err

    # Update the app, returns a promise
    update : ( newJson, fastUpdate )->
      if not @isApp() then return @__returnErrorPromise()
      oldState = @get("state")
      @set("state", OpsModelState.Updating)
      @attributes.progress = 0

      self = @
      errorHandler = ( err )->
        self.attributes.progress = 0
        self.set { state : oldState }
        throw err

      ApiRequest("app_update", {
        region_name : @get("region")
        spec        : newJson
        app_id      : @get("id")
        fast_update : fastUpdate
      }).then ()->
        self.__updateAppDefer = d = Q.defer()
        d.promise.then ()->
          self.__jsonData = newJson
          self.set {
            name  : newJson.name
            state : OpsModelState.Running
          }
        , errorHandler
      , errorHandler

    # Replace the data in mongo with new data. This method doesn't trigger an app update.
    saveApp : ( newJson )->
      d = Q.defer()
      d.resolve()
      self = @
      newJson.changed = false
      d.promise.then ()->
        self.__jsonData = newJson
        self
      # ApiRequest("app_save_info", {

      # })

    setStatusProgress : ( steps, totalSteps )->
      progress = parseInt( steps * 100.0 / totalSteps )
      if @.attributes.progress != progress
        # Disable Backbone's auto triggering change event. Because I don't wan't that changing progress will trigger `change:progress` and `change`
        @attributes.progress = progress
        @trigger "change:progress", @, progress
      return

    isProcessing : ()->
      state = @attributes.state
      state is OpsModelState.Initializing || state is OpsModelState.Stopping || state is OpsModelState.Updating || state is OpsModelState.Terminating || state is OpsModelState.Starting

    setStatusWithApiResult : ( state )-> @set "state", OpsModelState[ state ]

    setStatusWithWSEvent : ( operation, state, error )->
      # operation can be ["launch", "stop", "start", "update", "terminate"]
      # state can have "completed", "failed", "progressing", "pending"
      switch operation
        when "launch"
          if state.completed
            toState = OpsModelState.Running
          else if state.failed
            toState = OpsModelState.Destroyed
        when "stop"
          if state.completed
            toState = OpsModelState.Stopped
          else if state.failed
            toState = OpsModelState.Running
        when "update"
          if not @__updateAppDefer
            console.warn "UpdateAppDefer is null when setStatusWithWSEvent with `update` event."
          else
            d = @__updateAppDefer
            @__updateAppDefer = null
            if state.completed
              d.resolve()
            else
              d.reject McError( ApiRequest.Errors.OperationFailure, error )
        when "terminate"
          if state.completed
            toState = OpsModelState.Destroyed
          else
            @attributes.terminateFail = false
            @set "terminateFail", true
        when "start"
          if state.completed
            toState = OpsModelState.Running
          else
            toState = OpsModelState.Stopped

      if error
        @attributes.opsActionError = error

      if toState is OpsModelState.Destroyed
        @__destroy()

      else if toState
        @attributes.progress = 0
        @set "state", toState
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
      Thumbnail.remove( @get("id") )

      # Directly modify the attr to avoid sending an event, becase destroy would trigger an update event
      @attributes.state = OpsModelState.Destroyed
      @trigger 'destroy', @, @collection

    __returnErrorPromise : ()->
      d = Q.defer()
      d.resolve McError( ApiRequest.Errors.InvalidMethodCall, "The method is not supported by this model." )
      d.promise

    # This method init a json for a newly created stack.
    __createRawJson : ()->
      id          : @get("id") or ""
      name        : @get("name")
      description : ""
      region      : @get("region")
      platform    : "ec2-vpc"
      state       : "Enabled"
      version     : "2014-02-17"
      component   : {}
      layout      : { size : [240, 240] }
      agent :
        enabled : true
        module  :
          repo : App.user.get("mod_repo")
          tag  : App.user.get("mod_tag")
      property :
        policy : { ha : "" }
        lease  : { action: "", length: null, due: null }
        schedule :
          stop   : { run: null, when: null, during: null }
          backup : { when : null, day : null }
          start  : { when : null }

    __initJsonData : ()->
      json = @__createRawJson()

      layout =
        VPC :
          coordinate : [5,3]
          size       : [60,60]
        RTB :
          coordinate : [50,5]

      component =
        KP :
          type : "AWS.EC2.KeyPair"
          name : "DefaultKP"
          resource : { KeyName : "DefaultKP" }
        SG :
          type : "AWS.EC2.SecurityGroup"
          name : "DefaultSG"
          resource :
            IpPermissions: [{
              IpProtocol : "tcp",
              IpRanges   : "0.0.0.0/0",
              FromPort   : "22",
              ToPort     : "22",
              Groups     : [{"GroupId":"","UserId":"","GroupName":""}]
            }],
            IpPermissionsEgress : [{
              FromPort: "0",
              IpProtocol: "-1",
              IpRanges: "0.0.0.0/0",
              ToPort: "65535"
            }],
            Default             : "true",
            GroupName           : "DefaultSG",
            GroupDescription    : 'Default Security Group'
        ACL :
          type : "AWS.VPC.NetworkAcl"
          name : "DefaultACL"
          resource :
            EntrySet : [
              {
                RuleAction : "allow"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : true
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 100
              }
              {
                RuleAction : "allow"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : false
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 100
              }
              {
                RuleAction : "deny"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : true
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 32767
              }
              {
                RuleAction : "deny"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : false
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 32767
              }
            ]
        VPC :
          type : "AWS.VPC.VPC"
          name : "vpc"
          resource : {}
        RTB :
          type     : "AWS.VPC.RouteTable"
          resource :
            AssociationSet : [{Main:"true"}]
            RouteSet       : [{
                State                : 'active',
                Origin               : 'CreateRouteTable',
                GatewayId            : 'local',
                DestinationCidrBlock : '10.0.0.0/16'
            }],

      # Generate new GUID for each component
      for id, comp of component
        comp.uid = MC.guid()
        json.component[ comp.uid ] = comp
        if layout[ id ]
          l = layout[id]
          l.uid = comp.uid
          json.layout[ comp.uid ] = l

      @__jsonData = json
      return
    }

  OpsModel.State = OpsModelState

  OpsModel
