
###
----------------------------
  The View for application
----------------------------
###

define [ "backbone", "./subviews/SessionDialog", "./subviews/HeaderView", "./subviews/WelcomeDialog" ], ( Backbone, SessionDialog, HeaderView, WelcomeDialog )->

  Backbone.View.extend {

    initialize : ()->
      @header = new HeaderView()

      new WelcomeDialog()
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

    showSessionDialog : ()->
      (new SessionDialog()).promise()

  }
