
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["ApiRequest", "backbone"], ( ApiRequest )->

  OpsModelState =
    UnRun   : 0
    Running : 1
    Stopped : 2

  OpsModel = Backbone.Model.extend {

    defaults : ()->
      updateTime : +(new Date())
      region     : ""
      usage      : ""
      serverId   : "" # If a model has a serverId, then it's saved in the server.
      state      : OpsModelState.UnRun

    isStack : ()-> @state is OpsModelState.UnRun
    isApp   : ()-> @state isnt OpsModelState.UnRun

    # Return true if the stack is saved in the server.
    presisted : ()-> !!@serverId

    # Save the stack in server, returns a promise
    save : ()->
      if @isApp() then return @__returnErrorPromise()

    # Delete the stack in server, returns a promise
    remove : ()->
      if @isApp() then return @__returnErrorPromise()

    # Stop the app, returns a promise
    stop : ()->
      if not @isApp() then return @__returnErrorPromise()
      if @state is OpsModelState.Stopped
        console.warn "The app #{@get("serverId")} has already stopped. But we are still sending a request to the server to stop it."

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
