
define [ "./SessionDialogView", "ApiRequest", "common_handle", "event" ], ( SessionDialogView, ApiRequest, common_handle, ide_event )->

  SessionDialogModel = Backbone.Model.extend {

    closeSession : ()->
      common_handle.cookie.deleteCookie()
      window.location.href = "/login/"
      return

    connect : ( password )->
      ApiRequest("login", {password:password}).then ( result )=>
        common_handle.cookie.setCookie result

        @trigger "CONNECTED"

        # Legacy Code
        ide_event.trigger ide_event.UPDATE_APP_LIST
        ide_event.trigger ide_event.UPDATE_DASHBOARD
        ide_event.trigger ide_event.RECONNECT_WEBSOCKET

        window.location.href = "/" if !MC.data.is_loading_complete
        return
  }

  CurrentSessionDialog = null
  SessionDialog = ()->
    if CurrentSessionDialog
      return

    CurrentSessionDialog = this

    model = new SessionDialogModel()
    view  = new SessionDialogView({model:model})
    view.render()

    model.on "CONNECTED", ()->
      CurrentSessionDialog = null
      model.off()
      view.remove()

    return


  SessionDialog
