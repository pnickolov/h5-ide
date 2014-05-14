#############################
#  View(UI logic) for dialog
#############################

define [ "./WelcomeTpl", 'i18n!nls/lang.js', "backbone" ], ( WelcomeTpl, lang ) ->

    WelcomeDialog = Backbone.View.extend {

      events :
        "click #WelcomeSkip"     : "skip"
        "click #WelcomeBack"     : "back"
        "click #WelcomeDone"     : "done"
        "click #WelcomeClose"    : "close"
        "click #CredSetupSubmit" : "submitCred"

        "keyup #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"

      initialize : ( options )->
        attributes =
          username : App.user.get("username")

        modal WelcomeTpl attributes
        @setElement $("#modal-box")
        return

      skip : ()->
        $("#WelcomeSettings").hide()
        $("#WelcomeSkipWarning").show()

      back : ()->
        $("#WelcomeSettings").show()
        $("#WelcomeSkipWarning").hide()

      done : ()->
        $("#WelcomeSettings, #WelcomeSkipWarning, #WelcomeCredUpdate").hide()
        $("#WelcomeDoneWrap").show()
        if App.user.hasCredential()
          $("#WelcomeDoneTitDemo").hide()
          $("#WelcomeDoneTit").children("span").text( App.user.get("account") )
        else
          $("#WelcomeDoneTitDemo").show()
          $("#WelcomeDoneTit").hide()

      close : ()->
        modal.close()

      updateSubmitBtn : ()->
        account    = $("#CredSetupAccount").val()
        accesskey  = $("#CredSetupAccessKey").val()
        privatekey = $("#CredSetupSecretKey").val()

        if account.length and accesskey.length and privatekey.length
          $("#CredSetupSubmit").removeAttr "disabled"
        else
          $("#CredSetupSubmit").attr "disabled", "disabled"
        return

      submitCred : ()->
        # First validate credential
        $("#WelcomeSettings").hide()
        $("#WelcomeCredUpdate").show()

        accesskey  = $("#CredSetupAccessKey").val()
        privatekey = $("#CredSetupSecretKey").val()

        self = this

        App.user.validateCredential( accesskey, privatekey ).then ()->
          self.setCred()
          return
        , ()->
          $("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_VALIDATE
          self.showCredSetup()
          return

      setCred : ()->
        account    = $("#CredSetupAccount").val()
        accesskey  = $("#CredSetupAccessKey").val()
        privatekey = $("#CredSetupSecretKey").val()

        self = this
        App.user.changeCredential( account, accesskey, privatekey, true ).then ()->
          self.done()
          return
        , ( err )->
          $("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_UPDATE
          self.showCredSetup()
          return

      showCredSetup : ()->
        $("#WelcomeDialog").children().hide()
        $("#WelcomeSettings").show()
        $("#CredSetupAccount").focus()[0].select()
        @updateSubmitBtn()
        return
    }

    WelcomeDialog
