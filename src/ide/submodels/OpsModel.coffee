
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["ApiRequest", "constant", "backbone"], ( ApiRequest, constant )->

  OpsModelState =
    UnRun    : 0
    Running  : 1
    Stopped  : 2
    Starting : 3

  OpsModelStateDesc = ["", "Running", "Stopped", ""]

  OpsModel = Backbone.Model.extend {

    defaults : ()->
      updateTime : +(new Date())
      region     : ""
      usage      : ""
      state      : OpsModelState.UnRun

    initialize : ( attr, options )->
      if options && options.initJsonData
        @__initJsonData()
      return


    isStack : ()-> @attributes.state is   OpsModelState.UnRun
    isApp   : ()-> @attributes.state isnt OpsModelState.UnRun

    # Returns a plain object to represent this model.
    # If you want to access the JSON of the stack/app, use getJsonData() instead.
    toJSON : ()->
      o = Backbone.Model.prototype.toJSON.call( this )
      o.stateDesc = OpsModelStateDesc[ o.state ]
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

    # Stop the app, returns a promise
    stop : ()->
      if not @isApp() then return @__returnErrorPromise()
      if @attributes.state is OpsModelState.Stopped
        console.warn "The app #{@get("id")} has already stopped. But we are still sending a request to the server to stop it."

    # Terminate the app, returns a promise
    terminate : ()->
      if not @isApp() then return @__returnErrorPromise()


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
