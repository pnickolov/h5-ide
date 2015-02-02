
###
----------------------------
  A refactor version of previous lib/websocket
  The usage of Meteor seems to be wrong, but whatever.
----------------------------
###

define [ "Meteor", "backbone", "event", "MC" ], ( Meteor, Backbone, ide_event )->

  singleton     = null
  WEBSOCKET_URL = "#{MC.API_HOST}/ws/"

  # Meteor actually have a option to enable logging. But the goddamn library is not possible to customize.
  Meteor._debug = ()-> console.log.apply console, arguments



  # The websocket object does subscribe some basic collection.
  # One can also use it to subscribe other stuffs.
  Websocket = ()->
    if singleton then return singleton

    singleton = @

    # Create a promise to notify others that Websocket is ready.
    @__readyDefer = Q.defer()
    @connection   = Meteor.connect WEBSOCKET_URL, true
    @projects     = {}

    opts =
      connection : @connection

    @collection =
      project : new Meteor.Collection "project",  opts
      # request : new Meteor.Collection "request",  opts
      # stack   : new Meteor.Collection "stack",    opts
      # app     : new Meteor.Collection "app",      opts
      # imports : new Meteor.Collection "imports",  opts
      # status  : new Meteor.Collection "status",   opts

    # Trigger an event when connection state changed.
    Deps.autorun ()=> @statusChanged()

    @pipeChanges()

    # We start notifying in 5 seconds
    setTimeout ()=>
      @shouldNotify = true
      if not @connection.status.connected
        @statusChanged()
    , 5000

    this

  Websocket.prototype.statusChanged = ()->
    status = @connection.status().connected

    if status
      @shouldNotify = true

    # We should ignore some of the disconnected status at the beginning of the IDE
    if not @shouldNotify
      return

    @trigger "StatusChanged", status


  # When the session is lost and then re-accuqired. Call this method to re-subscribe
  # everything that's previous subscribed.
  Websocket.prototype.reconnect = ()->
    @subscribeErrorState = false

    ps = _.keys @projects
    @projects = {}
    for p in ps
      @subscribe( p )

    return

  # Watch changes of a project, keep track of the subscribtion
  # Auto-subscribe when connection lost.
  Websocket.prototype.subscribe = ( projectId )->
    if @projects[ projectId ] then return

    self = @
    callback =
      onReady : ()-> self.__readyDefer.resolve()
      onError : (e)-> self.onError(e, projectId)

    session  = App.user.get("session")
    usercode = App.user.get("usercode")

    @projects[ projectId ] = [
      @connection.subscribe "project", usercode, session, projectId , callback
      # @connection.subscribe "request", projectId, session, callback
      # @connection.subscribe "stack",   projectId, session, callback
      # @connection.subscribe "app",     projectId, session, callback
      # @connection.subscribe "imports", projectId, session, callback
      # @connection.subscribe "status",  projectId, session, callback
    ]
    return

  Websocket.prototype.unsubscribe = ( projectId )->
    for subscription in @projects[ projectId ]
      subscription.stop()

    delete @projects[ projectId ]
    return

  # Return a promise that will be resolve when the websocket is ready.
  # Websocket will be ready after the first data is fetched.
  Websocket.prototype.ready   = ()-> @__readyDefer.promise
  Websocket.prototype.isReady = ()-> !@__readyDefer.isPending()

  # Whenever an error posted from the backend. The subscription will be removed.
  # The error is typically the "Invalid session error".
  # We notitfy the others to handle this error.
  Websocket.prototype.onError = ( error, projectId )->
    console.error "Websocket/Meteor Error:", error
    if not @subscribeErrorState
      @subscribeErrorState = true
      try
        @unsubscribe( projectId )
      catch e
        # Not sure if Meteor throws error when calling stop() on a disconnected subscription.
        # So we use a try / catch here.
      @trigger "Disconnected"
    return

  # The code is copied from the deprecated ide/deprecated/ide.coffee
  # It seems like it just pipe the changes of Request/VisualizeVpc to other places.
  # We can place all the watching code here, and re-pipe it to via ide_event,
  # and we can also place the watching code in the other place.
  Websocket.prototype.pipeChanges = ()->
    self = this

    return

    # request list
    @collection.request.find().fetch()
    @collection.request.find().observeChanges {
      added : (idx, dag) ->
        self.trigger "requestChange", idx, dag
      changed : (idx, dag) ->
        self.trigger "requestChange", idx, dag
    }

    # import list
    @collection.imports.find().fetch()
    @collection.imports.find().observe {
      added : (idx, dag) ->
        self.trigger "visualizeUpdate", idx
      changed : (idx, dag) ->
        self.trigger "visualizeUpdate", idx
    }

    # state status
    @collection.status.find().fetch()
    @collection.status.find().observe {
      added : (idx, statusData) ->
        ide_event.trigger ide_event.UPDATE_STATE_STATUS_DATA, 'add', idx, statusData
        ide_event.trigger ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR, if idx then [idx.res_id] else []

      changed: ( newDocument, oldDocument ) ->
        ide_event.trigger ide_event.UPDATE_STATE_STATUS_DATA, 'change', newDocument, oldDocument
        ide_event.trigger ide_event.UPDATE_STATE_STATUS_DATA_TO_EDITOR, if newDocument then [newDocument.res_id] else []
    }

  _.extend Websocket.prototype, Backbone.Events

  Websocket
