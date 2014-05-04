
define [ 'i18n!nls/lang.js' ], ( lang ) ->

  SessionDialogView = Backbone.View.extend {

    events :
      'click #SessionReconnect'   : 'showReconnect'
      'click #SessionClose'       : 'closeSession'
      'click #SessionClose2'      : 'closeSession'
      'click #SessionConnect'     : 'connect'
      'keypress #SessionPassword' : 'passwordChanged'

    render : () ->
      modal MC.template.sessionDialog(), false

      @setElement $('#modal-wrap')
      return

    showReconnect : ()->
      $(".invalid-session .confirmSession").hide()
      $(".invalid-session .reconnectSession").show()
      return

    closeSession : ()-> App.closeSession()

    connect : ()->
      if $("#SessionConnect").is(":disabled") then return

      $("#SessionConnect").attr "disabled", "disabled"
      App.user.acquireSession( $("#SessionPassword").val() ).then ()=>
        @remove()
        return
      , ( error )->
        $("#SessionConnect").removeAttr "disabled"
        notification 'error', lang.ide.NOTIFY_MSG_WARN_AUTH_FAILED
        $("#SessionPassword").toggleClass "parsley-error", true
        return

    passwordChanged : ( evt )->
      $("#SessionPassword").toggleClass "parsley-error", false
      if ($("#SessionPassword").val() || "").length >= 6
        $("#SessionConnect").removeAttr "disabled"
      else
        $("#SessionConnect").attr "disabled", "disabled"

      if evt.which is 13 then @connect()
      return
  }

  SessionDialogView
