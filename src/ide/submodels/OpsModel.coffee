
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["ApiRequest", "backbone"], ( ApiRequest )->

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

    isStack : ()-> @attributes.state is   OpsModelState.UnRun
    isApp   : ()-> @attributes.state isnt OpsModelState.UnRun

    toJSON : ()->
      o = Backbone.Model.prototype.toJSON.call( this )
      o.stateDesc = OpsModelStateDesc[ o.state ]
      o

    # Return true if the stack is saved in the server.
    isPresisted : ()-> !!@get("id")

    # Return true if the stack/app should be show to the user.
    isExisting : ()-> @get("id") && @get("state") isnt OpsModelState.Starting

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

    __returnErrorPromise : ()->
      d = Q.defer()
      d.resolve McError( ApiRequest.Errors.InvalidMethodCall, "The method is not supported by this model." )
      d.promise

    # Overriden model methods so that user won't call it acidentally
    destroy : ()->
      console.info "OpsModel's destroy() doesn't do anything. You probably want to call remove(), stop() or terminate()"


  }

  OpsModel.State = OpsModelState

  OpsModel
