
###
----------------------------
  The View for application
----------------------------
###

define [
  "backbone"
  "./subviews/SessionDialog"
  "./subviews/AppTpl"
  "./subviews/FullnameSetup"
  'i18n!/nls/lang.js'
  'constant'
], ( Backbone, SessionDialog, AppTpl, FullnameSetup, lang, constant )->

  Backbone.View.extend {

    el : $("body")[0]

    events :
      "click .click-select" : "selectText"

    initialize : ()->
      $(window).on "beforeunload", @checkUnload
      $(window).on 'keydown', @globalKeyEvent

      if not App.user.fullnameNotSet() then new FullnameSetup()
      return

    checkUnload : ()-> if App.canQuit() then undefined else lang.IDE.BEFOREUNLOAD_MESSAGE

    hideGlobalLoading : ()-> $("#GlobalLoading").hide()

    globalKeyEvent: (event) ->
      nodeName = event.target.nodeName.toLowerCase()
      if nodeName is "input" or nodeName is "textarea" or event.target.contentEditable is 'true'
        return

      switch event.which
        when 8
          event.preventDefault()
          return
        when 191
          App.loadUrl( "/cheatsheet" )
          return false

      return

    toggleWSStatus : ( isConnected )->
      if isConnected
        $(".disconnected-msg").remove()
      else
        if $(".disconnected-msg").show().length > 0
          return

        $( AppTpl.disconnectedMsg() ).appendTo("body").on "mouseover", ()->
          $(".disconnected-msg").addClass "hovered"
          $("body").on "mousemove.disconnectedmsg", ( e )->
            msg = $(".disconnected-msg")

            if not msg.length
              $("body").off "mousemove.disconnectedmsg"
              return

            pos = msg.offset()
            x = e.pageX
            y = e.pageY
            if x < pos.left || y < pos.top || x >= pos.left + msg.outerWidth() || y >= pos.top + msg.outerHeight()
              $("body").off "mousemove.disconnectedmsg"
              msg.removeClass "hovered"
            return
          return

    showSessionDialog : ()-> (new SessionDialog()).promise()

    # This is use to select text when clicking on the text.
    selectText : ( event )->
      try
        range = document.body.createTextRange()
        range.moveToElementText event.currentTarget
        range.select()
        console.warn "Select text by document.body.createTextRange"
      catch e
        if window.getSelection
          range = document.createRange()
          range.selectNode event.currentTarget
          window.getSelection().addRange range
          console.warn "Select text by document.createRange"
      return false


    askForForceTerminate : ( model )->
      if not model.get("terminateFail") then return

      new modalPlus({
        title: lang.TOOLBAR.POP_FORCE_TERMINATE
        width: 390
        template: AppTpl.forceTerminateApp {name: model.get("name")}
        confirm: {text: lang.TOOLBAR.POP_BTN_DELETE_STACK,  color: "red"}
      }).on "confirm", ()->
        model.terminate( true ).fail (err)->
          error = if err.awsError then err.error + "." + err.awsError else err.error
          notification sprintf lang.NOTIFY.ERROR_FAILED_TERMINATE, name, error
        return
      return

    notifyUnpay : ()->
      notification "error", "Failed to charge your account. Please update your billing info."
      return
  }
