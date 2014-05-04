
###
----------------------------
  This is the core / entry point / controller of the whole IDE.
  It contains some basical logics to maintain the IDE. And it holds other components
  to provide other functionality
----------------------------
###

define [ "./Websocket", "./ApplicationView", "event" ], ( Websocket, ApplicationView, ide_event )->

  VisualOps = ()->
    if window.App
      console.error "Application is already created."
      return

    window.App = this

    @view = new ApplicationView()

    @createWebsocket()
    return

  VisualOps.prototype.createWebsocket = ()->
    @WS = new Websocket()

    @WS.on "Disconnected", ()->
      # LEGACY code
      ide_event.trigger ide_event.SWITCH_MAIN
      require [ 'component/session/SessionDialog' ], ( SessionDialog )-> new SessionDialog()

    @WS.on "StatusChanged", ( isConnected )=>
      console.info "Websocket Status changed, isConnected:", isConnected
      @view.toggleWSStatus( isConnected )

  VisualOps
