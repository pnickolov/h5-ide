
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
  "./Router"
  "i18n!/nls/lang.js"
], ( Websocket, ApplicationView, ApplicationModel, User, SceneManager, Router, lang )->

  VisualOps = ()->
    if window.App
      console.error "Application is already created."
      return

    window.Router = new Router()
    window.App    = this
    return

  # initialize returns a promise that will be resolve when the application is ready.
  VisualOps.prototype.initialize = ()->

    @__createUser()
    @__createWebsocket()

    @sceneManager = new SceneManager()

    # view / model depends on User and Websocket
    @model  = new ApplicationModel()
    @view = new ApplicationView()

    # This function returns a promise
    fetchModel = @model.fetch().fail ( err )->
      notification lang.NOTIFY.CANNOT_LOAD_APPLICATION_DATA
      throw err

    Q.all([ @user.fetch(), fetchModel ]).then ()->
      App.view.hideGlobalLoading()
      window.Router.start()

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
    @user.on "SessionUpdated", ()=> @WS.reconnect()
    return

  # This method will prompt a dialog to let user to re-acquire the session
  VisualOps.prototype.acquireSession = ()-> @view.showSessionDialog()

  VisualOps.prototype.logout = ()->
    App.user.logout()

    p = window.location.pathname
    if p is "/"
      p = window.location.hash.replace("#", "/")

    if p and p isnt "/"
      window.location.href = "/login?ref=" + p
    else
      window.location.href = "/login"
    return

  # Return true if the ide can quit now.
  VisualOps.prototype.canQuit = ()-> !@sceneManager.hasUnsaveScenes()

  VisualOps
