#############################
#  View(UI logic) for dialog
#############################

define [ "./WelcomeTpl", "UI.modalplus", 'i18n!nls/lang.js', "backbone" ], ( WelcomeTpl, Modal, lang ) ->

    WelcomeDialog = Backbone.View.extend {

      events :
        "click #WelcomeSkip"     : "skip"
        "click #WelcomeBack"     : "back"
        "click #WelcomeDone"     : "skipDone"
        "click #WelcomeClose"    : "close"
        "click #CredSetupSubmit" : "submitCred"

        "keyup #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"

      initialize : ( options )->
        attributes =
          username : App.user.get("username")

        if options and options.askForCredential
          title = lang.ide.WELCOME_PROVIDE_CRED_TIT
          attributes.noWelcome = true
        else
          title = lang.ide.WELCOME_DIALOG_TIT

        @modal = new Modal {
          title         : title
          template      : WelcomeTpl( attributes )
          width         : "600"
          disableClose  : true
          disableFooter : true
          compact       : true
          hideClose     : true
          cancel        :
              hide : true
        }
        @modal.tpl.find(".context-wrap").attr("id", "WelcomeDialog")
        @setElement @modal.tpl
        return

      skip : ()->
        $("#WelcomeSettings").hide()
        $("#WelcomeSkipWarning").show()

      back : ()->
        $("#WelcomeSettings").show()
        $("#WelcomeSkipWarning").hide()

      skipDone : ()->
        if not App.user.hasCredential()
          @done()
          return

        $("#CredSetupAccount").val("")
        $("#CredSetupAccessKey").val("")
        $("#CredSetupSecretKey").val("")

        $("#WelcomeSkipWarning").hide()
        $("#WelcomeCredUpdate").show()

        @setCred()
        return

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
        @modal.close()
        App.openSampleStack(true)

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

        # A quickfix to avoid the limiation of the api.
        # Avoid user setting the account to demo_account
        if account is "demo_account"
          account = "user_demo_account"
          $("#CredSetupAccount").val(account)

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
