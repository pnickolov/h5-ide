
###
----------------------------
  The View for application
----------------------------
###

define [ "backbone", "./subviews/SessionDialog", "./subviews/HeaderView", "./subviews/WelcomeDialog", "./subviews/SettingsDialog" ], ( Backbone, SessionDialog, HeaderView, WelcomeDialog, SettingsDialog )->

  Backbone.View.extend {

    el : "body"

    events :
      "click .click-select" : "selectText"

    initialize : ()->
      @header = new HeaderView()

      @listenTo App.user, "change:state", @toggleWelcome

      ### env:dev ###
      require ["./ide/subviews/DebugTool"], (DT)-> new DT()
      ### env:dev:end ###
      ### env:debug ###
      require ["./ide/subviews/DebugTool"], (DT)-> new DT()
      ### env:debug:end ###
      return

    toggleWSStatus : ( isConnected )->
      if isConnected
        $(".disconnected-msg").remove()
      else
        if $(".disconnected-msg").show().length > 0
          return

        $( MC.template.disconnectedMsg() ).appendTo("body").on "mouseover", ()->
          $(".disconnected-msg").addClass "hovered"
          $("body").on "mousemove.disconnectedmsg", ( e )->
            msg = $(".disconnected-msg")
            pos = msg.offset()
            x = e.pageX
            y = e.pageY
            if x < pos.left || y < pos.top || x >= pos.left + msg.outerWidth() || y >= pos.top + msg.outerHeight()
              $("body").off "mousemove.disconnectedmsg"
              msg.removeClass "hovered"
            return
          return

    toggleWelcome : ()->
      if App.user.isFirstVisit()
        new WelcomeDialog()
      return

    showSessionDialog : ()->
      (new SessionDialog()).promise()

    showSettings : ( tab )->
      new SettingsDialog({ defaultTab:tab })
      return

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

  }
