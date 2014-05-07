#############################
#  View(UI logic) for dialog
#############################

define [ "./SettingsDialogTpl", 'i18n!nls/lang.js', "backbone" ], ( SettingsTpl, lang ) ->

    SettingsDialog = Backbone.View.extend {

      events :
        "click #SettingsNav span"        : "switchTab"
        "click #AccountPwd"              : "showPwd"
        "click #AccountCancelPwd"        : "hidePwd"
        "click #AccountUpdatePwd"        : "changePwd"
        "click .cred-setup, cred-cancel" : "showCredSetup"
        "click .cred-setup-cancel"       : "cancelCredSetup"
        "click #CredSetupRemove"         : "showRemoveCred"
        "click #CredRemoveConfirm"       : "removeCred"
        "click #CredSetupSubmit"         : "submitCred"
        "click #CredSetupConfirm"        : "confirmCred"

        "keyup #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"

      initialize : ( options )->

        attributes =
          username     : App.user.get("username")
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

          credRemoveTitle : sprintf lang.ide.SETTINGS_CRED_REMOVE_TIT, App.user.get("username")

        modal SettingsTpl attributes
        @setElement $("#modal-box")

        defaultTab = 0
        if options then defaultTab = options.defaultTab || 0
        $("#SettingsNav").children().eq( defaultTab ).click()
        return

      updateCredSettings : ()->
        attributes =
          username     : App.user.get("username")
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

          credRemoveTitle : sprintf lang.ide.SETTINGS_CRED_REMOVE_TIT, App.user.get("username")

        $("#modal-box").html SettingsTpl attributes
        $("#SettingsNav").children().eq( SettingsDialog.TAB.Credential ).click()



      switchTab : ( evt )->
        $this = $(evt.currentTarget)
        if $this.hasClass "selected" then return

        $("#SettingsBody").children().hide()
        $("#SettingsNav").children().removeClass("selected")
        $("#"+$this.addClass("selected").attr("data-target")).show()
        return

      showPwd : ()->
        $("#AccountPwd").hide()
        $("#AccountPwdWrap").show()
        $("#AccountCurrentPwd").focus()
        return

      hidePwd : ()->
        $("#AccountPwd").show()
        $("#AccountPwdWrap").hide()
        $("#AccountCurrentPwd, #AccountNewPwd").val("")
        $("#account-passowrd-info").empty()
        return

      changePwd : ()->
        old_pwd = $("#AccountCurrentPwd").val() || ""
        new_pwd = $("#AccountNewPwd").val() || ""
        if old_pwd.length < 6 or new_pwd.length < 6
          $('#account-passowrd-info').text lang.ide.SETTINGS_ERR_INVALID_PWD
          return

        $("#account-passowrd-info").empty()

        $("#AccountUpdatePwd").attr "disabled", "disabled"

        App.user.changePassword( old_pwd, new_pwd ).then ()->
          notification 'info', lang.ide.SETTINGS_UPDATE_PWD_SUCCESS
          $("#AccountCancelPwd").click()
          $("#AccountUpdatePwd").removeAttr "disabled"
          return
        , ( err )->
          if err.error is 2
            $('#account-passowrd-info').html "#{lang.ide.SETTINGS_ERR_WRONG_PWD} <a href='/reset/' target='_blank'>#{lang.ide.SETTINGS_INFO_FORGET_PWD}</a>"
          else
            $('#account-passowrd-info').text lang.ide.SETTINGS_UPDATE_PWD_FAILURE

          $("#AccountUpdatePwd").removeAttr "disabled"

        return

      showCredSetup : ()->
        $("#CredentialTab").children().hide()
        $("#CredSetupWrap").show()
        $("#CredSetupAccount").focus()[0].select()
        @updateSubmitBtn()
        return

      cancelCredSetup : ()->
        $("#CredentialTab").children().hide()
        if App.user.hasCredential()
          $("#CredAwsWrap").show()
        else
          $("#CredDemoWrap").show()
        return

      showRemoveCred : ()->
        $("#CredentialTab").children().hide()
        $("#CredRemoveWrap").show()
        return

      removeCred : ()->
        $("#CredentialTab").children().hide()
        $("#CredRemoving").show()
        $("#modal-box .modal-close").hide()

        self = this
        App.user.changeCredential().then ()->
          self.showLoadingResource()
          return
        , ()->
          $("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_REMOVE
          $("#modal-box .modal-close").show()
          self.showCredSetup()
        return

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
        $("#CredentialTab").children().hide()
        $("#CredUpdating").show()
        $("#modal-box .modal-close").hide()

        accesskey  = $("#CredSetupAccessKey").val()
        privatekey = $("#CredSetupSecretKey").val()

        self = this

        App.user.validateCredential( accesskey, privatekey ).then ()->
          self.showLoadingResource()
          self.setCred()
          return
        , ()->
          $("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_VALIDATE
          $("#modal-box .modal-close").show()
          $("#CredSetupAccessKey").val("")
          $("#CredSetupSecretKey").val("")
          self.showCredSetup()
          return

      setCred : ()->
        account    = $("#CredSetupAccount").val()
        accesskey  = $("#CredSetupAccessKey").val()
        privatekey = $("#CredSetupSecretKey").val()

        self = this
        App.user.changeCredential( account, accesskey, privatekey ).then ()->
          self.showLoadingResource()
        , ( err )->
          if err
            self.showCredConfirm()
          else
            self.showCredUpdateFail()
          return

      showCredUpdateFail : ()->
        $("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_UPDATE
        $("#modal-box .modal-close").show()
        self.showCredSetup()

      showCredConfirm : ()->
        $("#CredentialTab").children().hide()
        $("#CredConfirmWrap").show()
        $("#modal-box .modal-close").show()

      confirmCred : ()->
        account    = $("#CredSetupAccount").val()
        accesskey  = $("#CredSetupAccessKey").val()
        privatekey = $("#CredSetupSecretKey").val()

        # When we confirm to update. The key should be validated already.
        self = this
        App.user.validateCredential( account, accesskey, privatekey, true ).then ()->
          self.showLoadingResource()
        ()->
          self.showCredUpdateFail()
        return

      showLoadingResource : ()->
        $("#CredentialTab").children().hide()
        $("#CredLoadingRes").show()
        $("#modal-box .modal-close").hide()
        return

    }

    SettingsDialog.TAB =
      Normal     : 0
      Credential : 1

    SettingsDialog
