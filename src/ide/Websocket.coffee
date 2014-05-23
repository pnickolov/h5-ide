
###
----------------------------
  A refactor version of previous lib/websocket
  The usage of Meteor seems to be wrong, but whatever.
----------------------------
###

define [ "Meteor", "backbone", "event", "MC" ], ( Meteor, Backbone, ide_event )->

  WEBSOCKET_URL = "#{MC.API_HOST}/ws/"

  # Meteor actually have a option to enable logging. But the goddamn library is not possible to customize.
  Meteor._debug = ()-> console.log.apply console, arguments

  singleton = null

  Websocket = ()->
    if singleton then return singleton

    singleton = @

    # Create a promise to notify others that Websocket is ready.
    @__readyDefer = Q.defer()
    @__isReady    = false

    @connection = Meteor.connect WEBSOCKET_URL, true

    opts =
      connection : @connection

    @collection =
      request        : new Meteor.Collection "request",        opts
      request_detail : new Meteor.Collection "request_detail", opts
      stack          : new Meteor.Collection "stack",          opts
      app            : new Meteor.Collection "app",            opts
      status         : new Meteor.Collection "status",         opts
      imports        : new Meteor.Collection "imports",        opts

    # Trigger an event when connection state changed.
    Deps.autorun ()=> @statusChanged()

    @subscribe()
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

  # A Websocket can only subscribe once.
  Websocket.prototype.subscribe = ()->
    if @subscribed then return

    subscribed = true

    onReady = ()->
      @__isReady = true
      @__readyDefer.resolve()

    usercode = App.user.get 'usercode'
    session  = App.user.get 'session'
    callback = {
      onReady : _.bind onReady, @
      onError : _.bind @onError, @
    }

    @connection.subscribe "request", usercode, session, callback
    @connection.subscribe "stack",   usercode, session
    @connection.subscribe "app",     usercode, session
    @connection.subscribe "status",  usercode, session
    @connection.subscribe "imports", usercode, session
    return

  # Return a promise that will be resolve when the websocket is ready.
  # Websocket will be ready after the first data is fetched.
  Websocket.prototype.ready = ()-> @__readyDefer.promise
  Websocket.prototype.isReady = ()-> @__isReady

  # Whenever an error posted from the backend. The subscription will be removed.
  # The error is typically the "Invalid session error".
  # We notitfy the others to handle this error.
  Websocket.prototype.onError = ( error )->
    console.error "Websocket/Meteor Error:", error
    @subscribed = false
    @trigger "Disconnected"
    return

  # The code is copied from the deprecated ide/deprecated/ide.coffee
  # It seems like it just pipe the changes of Request/VisualizeVpc to other places.
  # We can place all the watching code here, and re-pipe it to via ide_event,
  # and we can also place the watching code in the other place.
  Websocket.prototype.pipeChanges = ()->
    self = this

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
        ide_event.trigger ide_event.UPDATE_IMPORT_ITEM, idx

      changed : (idx, dag) ->
        ide_event.trigger ide_event.UPDATE_IMPORT_ITEM, idx
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
