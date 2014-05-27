
###
----------------------------
  The View for application
----------------------------
###

define [
  "backbone"
  "./subviews/SessionDialog"
  "./subviews/HeaderView"
  "./subviews/WelcomeDialog"
  "./subviews/SettingsDialog"
  "./subviews/Navigation"
  "./subviews/AppTpl"
], ( Backbone, SessionDialog, HeaderView, WelcomeDialog, SettingsDialog, Navigation, AppTpl )->

  Backbone.View.extend {

    el : "body"

    events :
      "click .click-select" : "selectText"

    initialize : ()->
      @header = new HeaderView()

      new Navigation()

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

    toggleWelcome : ()->
      if App.user.isFirstVisit()
        new WelcomeDialog()
      return

    askForAwsCredential : ()-> new WelcomeDialog({ askForCredential : true })

    showSessionDialog : ()->
      (new SessionDialog()).promise()

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



    deleteStack : ( id ) ->
      name = App.model.stackList().get( id ).get( "name" )

      modal AppTpl.removeStackConfirm {
          msg : sprintf lang.ide.TOOL_POP_BODY_DELETE_STACK, name
      }

      $("#confirmRmStack").on "click", ()-> App.model.stackList().get( id ).remove(); return
      return

    duplicateStack : (id) ->
      name = App.model.stackList().get( id ).get( "name" )

      modal AppTpl.dupStackConfirm {
        newName : App.model.stackList().getNewName( name )
      }

      $("#confirmDupStackIpt").focus().select().on "keyup", ()->
        if $("#confirmDupStackIpt").val()
          $("confirmDupStack").removeAttr "disabled"
        else
          $("#confirmDupStack").attr "disabled", "disabled"
        return

      $("#confirmDupStack").on "click", ()->
        newName = $('#confirmDupStackIpt').val()

        #check duplicate stack name
        if newName.indexOf(' ') >= 0
          notification 'warning', lang.ide.PROP_MSG_WARN_WHITE_SPACE
        else if App.model.stackList().where({name:newName}).length
          notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
        else
          modal.close()
          m = App.model.stackList().get(id)
          if m then m.duplicate( newName )
        return

      return

    startApp : ( id )->
      name = App.model.appList().get( id ).get("name")
      modal AppTpl.startAppConfirm { name : name }
      $("#confirmStartApp").on "click", ()->
        App.model.appList().get( id ).start().fail ( err )->
          error = if err.awsError then err.error + "." + err.awsError else err.error
          notification "Fail to start your app \"#{name}\". (ErrorCode: #{error})"
          return
        return

      return

    stopApp : ( id )->
      app  = App.model.appList().get( id )
      name = app.get("name")

      modal AppTpl.stopAppConfirm {
        name       : name
        production : app.get("usage") is "production"
      }

      $("#confirmStopApp").on "click", ()->
        app.stop().fail ( err )->
          error = if err.awsError then err.error + "." + err.awsError else err.error
          notification "Fail to stop your app \"#{name}\". (ErrorCode: #{error})"
          return
        return

      $("#appNameConfirmIpt").on "keyup change", ()->
        if $("#appNameConfirmIpt").val() is name
          $("#confirmStopApp").removeAttr "disabled"
        else
          $("#confirmStopApp").attr "disabled", "disabled"
        return

      return

    terminateApp : ( id )->
      app  = App.model.appList().get( id )
      name = app.get("name")

      modal AppTpl.terminateAppConfirm {
        name       : name
        production : app.get("usage") is "production"
      }

      $("#appNameConfirmIpt").on "keyup change", ()->
        if $("#appNameConfirmIpt").val() is name
          $("#appTerminateConfirm").removeAttr "disabled"
        else
          $("#appTerminateConfirm").attr "disabled", "disabled"
        return

      $("#appTerminateConfirm").on "click", ()->
        app.terminate().fail ( err )->
          error = if err.awsError then err.error + "." + err.awsError else err.error
          notification "Fail to terminate your app \"#{name}\". (ErrorCode: #{error})"

          modal AppTpl.forceTerminateApp {
            name : name
          }

          $("#forceTerminateApp").on "click", ()->
            app.terminate().fail (err)->
              error = if err.awsError then err.error + "." + err.awsError else err.error
              notification "Fail to terminate your app \"#{name}\". (ErrorCode: #{error})"
            false
        return

      return
  }
