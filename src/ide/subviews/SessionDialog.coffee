
define [ 'i18n!/nls/lang.js', "./SessionDialogTpl", "UI.modalplus", "backbone" ], ( lang, template, modalPlus ) ->

  CurrentSessionDialog = null

  SessionDialogView = Backbone.View.extend {

    events :
      'keyup #SessionPassword'  : 'passwordChanged'

    constructor : ()->
      if CurrentSessionDialog
        return CurrentSessionDialog

      CurrentSessionDialog = this

      @defer = Q.defer()
      self = @
      @modal = new modalPlus {
        title: lang.IDE.DASH_INVALID_SESSION
        width: 400
        template: template()
        confirm: text: lang.IDE.DASH_LBL_CONNECT
        cancel: text: lang.IDE.DASH_LBL_CLOSE_SESSION, color: "red"
      }
      @modal.on "confirm", -> self.showReconnect()
      @modal.on "cancel",  -> self.closeSession()
      @modal.on "close",   -> self.closeSession()

      @setElement $('#modal-wrap')


    promise : ()-> @defer.promise

    showReconnect : ()->
      $(".invalid-session .confirmSession").hide()
      $(".invalid-session .reconnectSession").show()
      @modal.find(".modal-confirm").text(lang.IDE.DASH_LBL_CONNECT).attr("disabled", "disabled")
      @modal.off "confirm"
      @modal.on "confirm", _.bind @connect, @
      return

    closeSession : ()-> App.logout()

    connect : ()->
      if @modal.find(".modal-confirm").is(":disabled") then return

      @modal.find(".modal-confirm").attr "disabled", "disabled"
      App.user.acquireSession( $("#SessionPassword").val() ).then ()=>
        @remove()
        @defer.resolve()

        App.ignoreChangesWhenQuit()
        window.location.reload()
        return
      , ( error )->
        @modal.find(".modal-confirm").removeAttr "disabled"
        notification 'error', lang.NOTIFY.WARN_AUTH_FAILED
        $("#SessionPassword").toggleClass "parsley-error", true
        return

    passwordChanged : ( evt )->
      $("#SessionPassword").toggleClass "parsley-error", false
      if ($("#SessionPassword").val() || "").length >= 6
        @modal.find(".modal-confirm").removeAttr "disabled"
      else
        @modal.find(".modal-confirm").attr "disabled", "disabled"

      if evt.which is 13 then @connect()
      return
  }

  SessionDialogView
