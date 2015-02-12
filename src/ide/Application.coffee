
###
----------------------------
  This is the core / entry point / controller of the whole IDE.
----------------------------

  It contains some basical logics to maintain the IDE. And it holds other components
  to provide other functionality
###

define [
  "./Websocket"
  "./ApplicationView"
  "./ApplicationModel"
  "./User"
  "./SceneManager"
  "ApiRequest"
  "i18n!/nls/lang.js"
  "UI.notification"

  # Extra depedencies
  "./submodels/OpsModelAws"
  "./submodels/OpsModelOs"
], ( Websocket, ApplicationView, ApplicationModel, User, SceneManager, ApiRequest, lang )->


  VisualOps = ()->
    if window.App
      console.error "Application is already created."
      return

    window.App = this
    return

  # initialize returns a promise that will be resolve when the application is ready.
  VisualOps.prototype.initialize = ()->

    @__createUser()
    @__createWebsocket()

    @sceneManager = new SceneManager()

    # view / model depends on User and Websocket
    @model = new ApplicationModel()
    @view  = new ApplicationView()

    # This function returns a promise
    self = @
    jobs = @user.fetch().then ()->
      self.model.fetch().fail ( err )->
        notification "error", lang.NOTIFY.CANNOT_LOAD_APPLICATION_DATA, false
        # Returns a promise that will never fulfilled, so that we will stay in loading forever.
        d = Q.defer()
        d.promise

    jobs.then ()->
      App.view.hideGlobalLoading()
      App.view.init()
    , ( err )->

      # If userdata/appdata fails to load
      # We might want to do some error handling here.
      if err.error < 0
        if err.error is ApiRequest.Errors.Network500
          # Server down
          window.location = "/500"
        else
          # Network Error, Try reloading
          window.location.reload()
      else
        # If there's service error. I think we need to logout, because I guess it's because the session is not right.
        App.logout()
      return

  VisualOps.prototype.__createWebsocket = ()->
    @WS = new Websocket()

    @WS.on "Disconnected", ()-> App.acquireSession()

    @WS.on "StatusChanged", ( isConnected )->
      console.info "Websocket Status changed, isConnected:", isConnected
      if App.view then App.view.toggleWSStatus( isConnected )

    return

  VisualOps.prototype.__createUser = ()->
    @user = new User()
    # The Websockets subscription will be lost if we have an invalid session.
    # @user.on "SessionUpdated", ()=> @WS.reconnect()
    return

  # This method will prompt a dialog to let user to re-acquire the session
  VisualOps.prototype.acquireSession = ()-> @view.showSessionDialog()

  VisualOps.prototype.logout = ()->
    App.user.logout()
    @ignoreChangesWhenQuit()

    p = window.location.pathname
    if p is "/"
      p = window.location.hash.replace("#", "/")

    if p and p isnt "/"
      window.location.href = "/login?ref=" + p
    else
      window.location.href = "/login"
    return

  VisualOps.prototype.ignoreChangesWhenQuit = ()-> @__ICWQ = true; return

  # Return true if the ide can quit now.
  VisualOps.prototype.canQuit = ()-> @__ICWQ or !@sceneManager.hasUnsaveScenes()

  # Whenever you want to navigate to other part of the application ( e.g. switching to other scene )
  # without a link, use this method with a corresponding url.
  VisualOps.prototype.loadUrl = ( url )-> window.Router.navigate url, {replace:true,trigger:true}

  VisualOps
