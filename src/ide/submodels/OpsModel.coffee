
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["ApiRequest", "constant", "component/exporter/Thumbnail", "backbone"], ( ApiRequest, constant, ThumbUtil )->

  OpsModelState =
    UnRun        : 0
    Running      : 1
    Stopped      : 2
    Initializing : 3
    Updating     : 4
    Stopping     : 5
    Terminating  : 6
    Destroyed    : 7

  OpsModelStateDesc = ["", "Running", "Stopped", "Starting", "Updating", "Stopping", "Terminating", ""]

  OpsModel = Backbone.Model.extend {

    defaults : ()->
      updateTime    : +(new Date())
      region        : ""
      usage         : ""
      state         : OpsModelState.UnRun
      terminateFail : false
      stoppable     : true # If the app has instance_store_ami, stoppable is false

    initialize : ( attr, options )->
      if options && options.initJsonData
        @__initJsonData()
      return


    isStack : ()-> @attributes.state is   OpsModelState.UnRun
    isApp   : ()-> @attributes.state isnt OpsModelState.UnRun

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
    isExisting : ()-> @get("id") && @get("state") isnt OpsModelState.Starting

    # Returns a promise that will resolve with the JSON data of the stack/app
    getJsonData : ()->
      if @__jsonData
        d = Q.defer()
        d.resolve @__jsonData
        return d.promise
      # TODO :

    # Save the stack in server, returns a promise
    save : ()->
      if @isApp() then return @__returnErrorPromise()

    # Delete the stack in server, returns a promise
    remove : ()->
      if @isApp() then return @__returnErrorPromise()

      @trigger 'destroy', @, @collection

      self = @
      ApiRequest("stack_remove",{
        region_name : @get("region")
        stack_id    : @get("id")
      }).fail ()->
        # If we cannot delete the stack, we just add it back to the stackList.
        App.model.stackList().add self

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
        ThumbUtil.save id, thumbnail
        attr.id = id
        collection.add( new OpsModel(attr) )

    # Stop the app, returns a promise
    stop : ()->
      if not @isApp() then return @__returnErrorPromise()
      if @attributes.state is OpsModelState.Stopped
        console.warn "The app #{@get("id")} has already stopped. But we are still sending a request to the server to stop it."

    # Terminate the app, returns a promise
    terminate : ()->
      if not @isApp() then return @__returnErrorPromise()


    setStatusProgress : ( steps, totalSteps )->
      progress = parseInt( steps * 100.0 / totalSteps )
      if @.attributes.progress != progress
        @set "progress", progress
      return

    isProcessing : ()->
      state = @attributes.state
      state is OpsModelState.Initializing || state is OpsModelState.Stopping || state is OpsModelState.Updating || state is OpsModelState.Terminating

    setStatusWithApiResult : ( state )-> @set "state", OpsModelState[ state ]

    setStatusWithWSEvent : ( operation, state )->
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
          if state.completed
            toState = OpsModelState.Running
          else
            @__updateStatus()
        when "terminate"
          if state.completed
            toState = OpsModelState.Destroyed
          else
            @attributes.terminateFail = false
            @set "terminateFail", true

      if toState
        @attributes.progress = 0
        @set "state", toState

      if toState is OpsModelState.Destroyed
        Backbone.Model.prototype.destroy.call this

      return

    __updateStatus : ()->
      ApiRequest("app_list",{app_ids:[@get("id")]}).then (res)->
        @setStatusWithApiResult( res[0].state )
        return

    ###
     Internal Methods
    ###
    # Overriden model methods so that user won't call it acidentally
    destroy : ()->
      console.info "OpsModel's destroy() doesn't do anything. You probably want to call remove(), stop() or terminate()"

    __returnErrorPromise : ()->
      d = Q.defer()
      d.resolve McError( ApiRequest.Errors.InvalidMethodCall, "The method is not supported by this model." )
      d.promise

    # This method init a json for a newly created stack.
    __initJsonData : ()->
      json =
        id          : ""
        name        : @get("name")
        description : ""
        region      : @get("region")
        platform    : "ec2-vpc"
        state       : "Enabled"
        version     : "2014-02-17"
        component   : {}
        layout      : { size : [240, 240] }
        agent :
          enabled : false
          module  :
            repo : App.user.get("mod_repo")
            tag  : App.user.get("mod_tag")
        property    :
          policy : { ha : "" }
          lease  : { action: "", length: null, due: null }
          schedule :
            stop   : { run: null, when: null, during: null }
            backup : { when : null, day : null }
            start  : { when : null }

      # Generate new GUID for each component
      for id, comp of constant.VPC_JSON_INIT_COMP
        newId = MC.guid()
        json.component[ newId ] = $.extend true, {}, comp
        if constant.VPC_JSON_INIT_LAYOUT[ id ]
          json.layout[ newId ] = $.extend true, {}, constant.VPC_JSON_INIT_LAYOUT[ id ]

      @__jsonData = json
      return
  }

  OpsModel.State = OpsModelState

  OpsModel
