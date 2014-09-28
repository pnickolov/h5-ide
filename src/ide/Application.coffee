
###
----------------------------
  This is the core / entry point / controller of the whole IDE.
----------------------------

  It contains some basical logics to maintain the IDE. And it holds other components
  to provide other functionality
###

define [
  "ApiRequest"
  "./Websocket"
  "./ApplicationView"
  "./ApplicationModel"
  "./User"
  "./subviews/SettingsDialog"
  "CloudResources"
  "./WorkspaceManager"
  "OpsModel"
  "JsonExporter"
  "constant"
  "i18n!/nls/lang.js"
  "underscore"
], ( ApiRequest, Websocket, ApplicationView, ApplicationModel, User, SettingsDialog, CloudResources, WorkspaceManager, OpsModel, JsonExporter, constant, lang )->

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

    @workspaces = new WorkspaceManager()

    # view / model depends on User and Websocket
    @model  = new ApplicationModel()
    @__view = new ApplicationView()

    # This function returns a promise
    fetchModel = @model.fetch().fail ( err )->
      notification lang.NOTIFY.CANNOT_LOAD_APPLICATION_DATA
      throw err
    Q.all [ @user.fetch(), fetchModel ]

  VisualOps.prototype.__createWebsocket = ()->
    @WS = new Websocket()

    @WS.on "Disconnected", ()=> @acquireSession()

    @WS.on "StatusChanged", ( isConnected )=>
      console.info "Websocket Status changed, isConnected:", isConnected
      if @__view then @__view.toggleWSStatus( isConnected )

    return


  VisualOps.prototype.__createUser = ()->
    @user = new User()

    @user.on "SessionUpdated", ()=>
      # In the previous version of IDE, we update the applist and dashboard when the
      # session is updated. But I don't think it's necessary.

      # The Websockets subscription will be lost if we have an invalid session.
      @WS.subscribe()

    @user.on "change:credential", ()=> @discardAwsCache()
    return

  # This method will prompt a dialog to let user to re-acquire the session
  VisualOps.prototype.acquireSession = ()-> @__view.showSessionDialog()

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
  VisualOps.prototype.canQuit = ()-> !@workspaces.hasUnsaveSpaces()


  VisualOps.prototype.showSettings = ( tab )-> new SettingsDialog({ defaultTab:tab })
  VisualOps.prototype.showSettings.TAB = SettingsDialog.TAB

  # Show a popup to ask the user to enter a credential
  VisualOps.prototype.askForAwsCredential = ()-> @__view.askForAwsCredential()

  # These functions are for consistent behavoir of managing stacks/apps
  VisualOps.prototype.deleteStack    = (id, name)-> @__view.deleteStack(id, name)
  VisualOps.prototype.duplicateStack = (id)-> @__view.duplicateStack(id)
  VisualOps.prototype.startApp       = (id)-> @__view.startApp(id)
  VisualOps.prototype.stopApp        = (id)-> @__view.stopApp(id)
  VisualOps.prototype.terminateApp   = (id)-> @__view.terminateApp(id)

  VisualOps.prototype.discardAwsCache = ()->
    App.model.clearImportOps()
    CloudResources.invalidate()

  # Creates a stack from the "json" and open it.
  # If it cannot import the json data, returns a string to represent the result.
  # otherwise it returns the workspace that works on the model
  VisualOps.prototype.importJson = ( json )->
    result = JsonExporter.importJson json

    if _.isString result then return result

    @openOps( @model.createStackByJson(result) )

  # This is a convenient method to open an editor for the ops model.
  VisualOps.prototype.openOps = ( opsModel, refresh )->
    if not opsModel then return

    if _.isString( opsModel )
      opsModel = @model.getOpsModelById( opsModel )

    if not opsModel
      console.warn "The OpsModel is not found when opening."
      return

    if opsModel.testState( OpsModel.State.Destroyed )
      console.error "The OpsModel is destroyed", opsModel
      return

    editor = @workspaces.find( opsModel )
    if editor and refresh
      editor.remove()
      editor = null

    if not editor
      editor = new OpsEditor(opsModel)

    editor.activate()
    editor

  # This is a convenient method to create a stack and then open an editor for it.
  VisualOps.prototype.createOps = ( region, cloudType, provider )->
    if not region then return
    editor = new OpsEditor( @model.createStack(region, cloudType, provider) )
    editor.activate()
    editor

  VisualOps
