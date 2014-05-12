
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
    Deps.autorun ()=>
      @trigger "StatusChanged", @connection.status().connected

    @subscribe()
    @pipeChanges()

    this

  # A Websocket can only subscribe once.
  Websocket.prototype.subscribe = ()->
    if @subscribed then return

    subscribed = true

    usercode = $.cookie 'usercode'
    session  = $.cookie 'session_id'
    callback = {
      onReady : _.bind @onReady, @
      onError : _.bind @onError, @
    }

    @connection.subscribe "request", usercode, session, callback
    @connection.subscribe "stack",   usercode, session
    @connection.subscribe "app",     usercode, session
    @connection.subscribe "status",  usercode, session
    @connection.subscribe "imports", usercode, session
    return

  Websocket.prototype.onReady = ()->
    # LEGACY Code
    ide_event.trigger ide_event.WS_COLLECTION_READY_REQUEST
    return

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
    # request list
    @collection.request.find().fetch()
    @collection.request.find().observeChanges {
      added : (idx, dag) ->
        ide_event.trigger ide_event.UPDATE_REQUEST_ITEM, idx, dag
      changed : (idx, dag) ->
        ide_event.trigger ide_event.UPDATE_REQUEST_ITEM, idx, dag
    }

    # import list
    @collection.imports.find().fetch()
    @collection.imports.find().observe {
      added : (idx, dag) ->
        ide_event.trigger ide_event.UPDATE_IMPORT_ITEM, idx

      changed : (idx, dag) ->
        ide_event.trigger ide_event.UPDATE_IMPORT_ITEM, idx
    }


  _.extend Websocket.prototype, Backbone.Events

  Websocket
