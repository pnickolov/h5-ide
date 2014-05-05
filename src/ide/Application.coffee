
###
----------------------------
  This is the core / entry point / controller of the whole IDE.
  It contains some basical logics to maintain the IDE. And it holds other components
  to provide other functionality
----------------------------
###

define [ "./Websocket", "./ApplicationView", "./User", "common_handle" ,"event" ], ( Websocket, ApplicationView, User, common_handle, ide_event )->

  VisualOps = ()->
    if window.App
      console.error "Application is already created."
      return

    window.App = this

    @view = new ApplicationView()

    @__createWebsocket()
    @__createUser()
    return

  VisualOps.prototype.__createWebsocket = ()->
    @WS = new Websocket()

    @WS.on "Disconnected", ()=> @acquireSession()

    @WS.on "StatusChanged", ( isConnected )=>
      console.info "Websocket Status changed, isConnected:", isConnected
      @view.toggleWSStatus( isConnected )


  VisualOps.prototype.__createUser = ()->
    @user = new User()
    @user.fetch()

    @user.on "SessionUpdated", ()=>
      # Legacy Code
      ide_event.trigger ide_event.UPDATE_APP_LIST
      ide_event.trigger ide_event.UPDATE_DASHBOARD

      # The Websockets subscription will be lost if we have an invalid session.
      @WS.subscribe()


  # This method will prompt a dialog to let user to re-acquire the session
  VisualOps.prototype.acquireSession = ()->
    # LEGACY code
    # Seems like in the old days, someone wants to swtich to dashboard.
    ide_event.trigger ide_event.SWITCH_MAIN
    @view.showSessionDialog()

  VisualOps.prototype.logout = ()->
    App.user.logout()
    window.location.href = "/login/"
    return


  VisualOps
