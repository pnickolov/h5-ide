
###
----------------------------
  The collection for stack / app
----------------------------

  This collection will trigger an "update" event when the list ( containing all visible items ) is changed.

###

define ["OpsModel", "constant", "backbone" ], ( OpsModel, constant )->

  STATEDEF = {}
  STATEDEF[ constant.OPS_CODE_NAME.LAUNCH ] = [
    OpsModel.State.Initializing
    OpsModel.State.Running
    OpsModel.State.Destroyed
    OpsModel.State.RollingBack
  ]
  STATEDEF[ constant.OPS_CODE_NAME.STOP ] = [
    OpsModel.State.Stopping
    OpsModel.State.Stopped
    OpsModel.State.Running
    OpsModel.State.RollingBack
  ]
  STATEDEF[ constant.OPS_CODE_NAME.START ] = [
    OpsModel.State.Starting
    OpsModel.State.Running
    OpsModel.State.Stopped
    OpsModel.State.RollingBack
  ]
  STATEDEF[ constant.OPS_CODE_NAME.TERMINATE ] = [
    OpsModel.State.Terminating
    OpsModel.State.Destroyed
    OpsModel.State.Stopped
    OpsModel.State.RollingBack
  ]
  STATEDEF[ constant.OPS_CODE_NAME.UPDATE ] = STATEDEF[ constant.OPS_CODE_NAME.STATE_UPDATE ] = [
    OpsModel.State.Updating
    OpsModel.State.Running
    OpsModel.State.Stopped
    OpsModel.State.RollingBack
  ]

  Notification = Backbone.Model.extend {

    default :
      isNew     : true
      startTime : 0
      duration  : 0
      action    : ""
      state     : null
      progress  : 0
      error     : ""

    constructor : ( app )->
      Backbone.Model.call this, { id : app.id }
      @__target = app
      @__targetProject = app.project()
      return

    target : ()-> @__target
    targetProject : ()-> @__targetProject

    remove : ()->
      @__target = null
      @stopListening()
      @trigger 'destroy', @, @collection
      return

    isNew : ()-> @get("isNew")

    markAsRead : ()->
      @attributes.isNew = false
      return

    markAsOld : ()->
      if @get("error")
        # Keep notification that have error message ("That is failed to terminate")
        @attributes.isNew = false
      else
        @remove()
      return

    updateWithRequest : ( req )->
      console.info "Updating notification", @, req

      if req.time_submit < @get("startTime")
        # The incoming request is older then what we have already processed. Ignore.
        console.info "Ingore notification since the req is old", @, req
        return

      if req.username isnt App.user.get("usercode")
        # The app which this notification bonds to, has been manipulating by other user in the project.
        # The notification will destroy itself in such a case.
        console.info "Removing notification since the app has been edited by other user.", @, req
        return @remove()

      # Duration
      if req.time_end and req.time_end > req.time_submit
        duration = req.time_end - req.time_submit
      else
        duration = 0

      # State / Error / Progress
      state    = null
      error    = ""
      progress = 0

      if req.state is constant.OPS_STATE.INPROCESS
        toStateIndex = 0
        step       = 0
        totalSteps = 1
        if req.dag and req.dag.step
          totalSteps = req.dag.step.length
          for i in req.dag.step
            if i[1] is "done" then ++step

          # Special treatment for failing to do a request.
          if req.dag.state is "Rollback"
            toStateIndex = 3

        progress = parseInt( step * 100.0 / totalSteps )

      else if req.state is constant.OPS_STATE.DONE
        toStateIndex = 1
      else
        toStateIndex = 2
        error = req.data


      ab = @attributes

      @set {
        startTime : req.time_submit
        duration  : duration
        action    : req.code
        error     : error
        progress  : progress
        state     : toStateIndex
        isNew     : (ab.startTime isnt req.time_submit) or (ab.duration isnt duration) or (ab.action isnt req.code) or (ab.error isnt error) or (ab.state isnt toStateIndex) or ab.isNew
      }
      return

    isProcessing  : ()-> @get("state") is 0
    isRollingBack : ()-> @get("state") is 4
    isSucceeded   : ()-> @get("state") is 1
    isFailed      : ()-> @get("state") is 2
  }

  NotificationCollection = Backbone.Collection.extend {
    model      : Notification
    comparator : ( m1, m2 )-> -(m1.attributes.startTime - m2.attributes.startTime)
    initialize : ()->
      # Re-sort the collection when any model is updated.
      @on "change:startTime", @sort, @
      return

    add : ( app, req )->
      n = new Notification( app )
      console.info "Added notification for app", n, req
      n.updateWithRequest( req )
      Backbone.Collection.prototype.add.call this, n
      n

    markAllAsRead : ()->
      changed = false
      for n in @models
        if n.get("isNew")
          changed = true
          n.markAsRead()

      if changed then @trigger "change"
      return
  }

  NotificationCollection
