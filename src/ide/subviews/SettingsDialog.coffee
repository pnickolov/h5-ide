#############################
#  View(UI logic) for dialog
#############################

define [ "./SettingsDialogTpl", 'i18n!/nls/lang.js', "ApiRequest", "UI.modalplus" ,"backbone" ], ( SettingsTpl, lang, ApiRequest, Modal ) ->

    SettingsDialog = Backbone.View.extend {

      events :
        "click #SettingsNav span"         : "switchTab"
        "click #AccountPwd"               : "showPwd"
        "click #AccountCancelPwd"         : "hidePwd"
        "click #AccountUpdatePwd"         : "changePwd"
        "click .cred-setup, .cred-cancel" : "showCredSetup"
        "click .cred-setup-cancel"        : "cancelCredSetup"
        "click #CredSetupRemove"          : "showRemoveCred"
        "click #CredRemoveConfirm"        : "removeCred"
        "click #CredSetupSubmit"          : "submitCred"
        "click #CredSetupConfirm"         : "confirmCred"

        "click #TokenCreate"               : "createToken"
        "click .tokenControl .icon-edit"   : "editToken"
        "click .tokenControl .icon-delete" : "removeToken"
        "click .tokenControl .tokenDone"   : "doneEditToken"
        "click #TokenRemove"               : "confirmRmToken"
        "click #TokenRmCancel"             : "cancelRmToken"

        "keyup  #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"
        "change #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"
        "change #AccountCurrentPwd, #AccountNewPwd"                          : "updatePwdBtn"
        "keyup  #AccountCurrentPwd, #AccountNewPwd"                          : "updatePwdBtn"

      initialize : ( options )->

        attributes =
          username     : App.user.get("username")
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

          credRemoveTitle : sprintf lang.ide.SETTINGS_CRED_REMOVE_TIT, App.user.get("username")
          credNeeded : !!App.model.appList().length

        @modal = new Modal {
          template: SettingsTpl attributes
          title: lang.ide.HEAD_LABEL_SETTING
          disableFooter: true
          compact: true
        }
        @setElement @modal.tpl

        tab = 0
        if options
          tab = options.defaultTab || 0

          if tab is SettingsDialog.TAB.CredentialInvalid
            @showCredSetup()
            @modal.tpl.find(".modal-close").hide()
            @modal.tpl.find("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_VALIDATE

          if tab < 0 then tab = Math.abs( tab )

        @modal.$("#SettingsNav").children().eq( tab ).click()

        @updateTokenTab()
        return

      updateCredSettings : ()->
        attributes =
          username     : App.user.get("username")
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

          credRemoveTitle : sprintf lang.ide.SETTINGS_CRED_REMOVE_TIT, App.user.get("username")

        @modal.$("#modal-box").html SettingsTpl attributes
        @modal.$("#SettingsNav").children().eq( SettingsDialog.TAB.Credential ).click()



      switchTab : ( evt )->
        $this = $(evt.currentTarget)
        if $this.hasClass "selected" then return

        @modal.$("#SettingsBody").children().hide()
        @modal.$("#SettingsNav").children().removeClass("selected")
        @modal.$("#"+$this.addClass("selected").attr("data-target")).show()
        return

      showPwd : ()->
        @modal.$("#AccountPwd").hide()
        @modal.$("#AccountPwdWrap").show()
        @modal.$("#AccountCurrentPwd").focus()
        return

      hidePwd : ()->
        @modal.$("#AccountPwd").show()
        @modal.$("#AccountPwdWrap").hide()
        @modal.$("#AccountCurrentPwd, #AccountNewPwd").val("")
        @modal.$("#AccountInfo").empty()
        return

      updatePwdBtn : ()->
        old_pwd = @modal.$("#AccountCurrentPwd").val() || ""
        new_pwd = @modal.$("#AccountNewPwd").val() || ""

        if old_pwd.length and new_pwd.length
          @modal.$("#AccountUpdatePwd").removeAttr "disabled"
        else
          @modal.$("#AccountUpdatePwd").attr "disabled", "disabled"
        return

      changePwd : ()->
        that = @
        old_pwd = @modal.$("#AccountCurrentPwd").val() || ""
        new_pwd = @modal.$("#AccountNewPwd").val() || ""
        if new_pwd.length < 6
          @modal.$('#AccountInfo').text lang.ide.SETTINGS_ERR_INVALID_PWD
          return

        @modal.$("#AccountInfo").empty()

        @modal.$("#AccountUpdatePwd").attr "disabled", "disabled"

        App.user.changePassword( old_pwd, new_pwd ).then ()->
          notification 'info', lang.ide.SETTINGS_UPDATE_PWD_SUCCESS
          that.modal.$("#AccountCancelPwd").click()
          that.modal.$("#AccountUpdatePwd").removeAttr "disabled"
          return
        , ( err )->
          if err.error is 2
            that.modal.$('#AccountInfo').html "#{lang.ide.SETTINGS_ERR_WRONG_PWD} <a href='/reset/' target='_blank'>#{lang.ide.SETTINGS_INFO_FORGET_PWD}</a>"
          else
            that.modal.$('#AccountInfo').text lang.ide.SETTINGS_UPDATE_PWD_FAILURE

          that.modal.$("#AccountUpdatePwd").removeAttr "disabled"

        return

      showCredSetup : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredSetupWrap").show()
        @modal.$("#CredSetupAccount").focus()[0].select()
        @modal.$("#CredSetupRemove").toggle App.user.hasCredential()
        @updateSubmitBtn()
        return

      cancelCredSetup : ()->
        @modal.$("#CredentialTab").children().hide()
        if App.user.hasCredential()
          @modal.$("#CredAwsWrap").show()
        else
          @modal.$("#CredDemoWrap").show()
        return

      showRemoveCred : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredRemoveWrap").show()
        return

      removeCred : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredRemoving").show()
        @modal.$("#modal-box .modal-close").hide()

        self = this
        App.user.changeCredential().then ()->
          self.updateCredSettings()
          return
        , ()->
          self.modal.$("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_REMOVE
          self.modal.$("#modal-box .modal-close").show()
          self.showCredSetup()
        return

      updateSubmitBtn : ()->
        account    = @modal.$("#CredSetupAccount").val()
        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        if account.length and accesskey.length and privatekey.length
          @modal.$("#CredSetupSubmit").removeAttr "disabled"
        else
          @modal.$("#CredSetupSubmit").attr "disabled", "disabled"
        return

      submitCred : ()->
        # First validate credential
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredUpdating").show()
        @modal.$("#modal-box .modal-close").hide()

        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        self = this

        App.user.validateCredential( accesskey, privatekey ).then ()->
          self.setCred()
          return
        , ()->
          self.modal.$("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_VALIDATE
          self.modal.$("#modal-box .modal-close").show()
          self.showCredSetup()
          return

      setCred : ()->
        account    = @modal.$("#CredSetupAccount").val()
        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        # A quickfix to avoid the limiation of the api.
        # Avoid user setting the account to demo_account
        if account is "demo_account"
          account = "user_demo_account"
          @modal.$("#CredSetupAccount").val(account)

        self = this
        App.user.changeCredential( account, accesskey, privatekey, false ).then ()->
          self.updateCredSettings()
        , ( err )->
          if err.error is ApiRequest.Errors.ChangeCredConfirm
            self.showCredConfirm()
          else
            self.showCredUpdateFail()
          return

      showCredUpdateFail : ()->
        @modal.$("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_UPDATE
        @modal.$("#modal-box .modal-close").show()
        @showCredSetup()

      showCredConfirm : ()->
        @modal.$("#CredentialTab").children().hide()
        @modal.$("#CredConfirmWrap").show()
        @modal.$("#modal-box .modal-close").show()

      confirmCred : ()->
        account    = @modal.$("#CredSetupAccount").val()
        accesskey  = @modal.$("#CredSetupAccessKey").val()
        privatekey = @modal.$("#CredSetupSecretKey").val()

        # When we confirm to update. The key should be validated already.
        self = this
        App.user.changeCredential( account, accesskey, privatekey, true ).then ()->
          self.updateCredSettings()
        , ()->
          self.showCredUpdateFail()
        return

      editToken : ( evt )->
        $t = $(evt.currentTarget)
        $p = $t.closest("li").toggleClass("editing", true)
        $p.children(".tokenName").removeAttr("readonly").focus().select()
        return

      removeToken : ( evt )->
        $p = $(evt.currentTarget).closest("li")
        name = $p.children(".tokenName").val()
        @rmToken = $p.children(".tokenToken").text()
        @modal.$("#TokenManager").hide()
        @modal.$("#TokenRmConfirm").show()
        @modal.$("#TokenRmTit").text( sprintf lang.ide.SETTINGS_CONFIRM_TOKEN_RM_TIT, name )
        return

      createToken : ()->
        @modal.$("#TokenCreate").attr "disabled", "disabled"

        self = this
        App.user.createToken().then ()->
          self.updateTokenTab()
          self.modal.$("#TokenCreate").removeAttr "disabled"
        , ()->
          notification "error", "Fail to create token, please retry."
          self.modal.$("#TokenCreate").removeAttr "disabled"
        return

      doneEditToken : ( evt )->
        $p = $(evt.currentTarget).closest("li").removeClass("editing")
        $p.children(".tokenName").attr "readonly", true

        token        = $p.children(".tokenToken").text()
        newTokenName = $p.children(".tokenName").val()

        for t in  App.user.get("tokens")
          if t.token is token
            oldName = t.name
          else if t.name is newTokenName
            duplicate = true

        if not newTokenName or duplicate
          $p.children(".tokenName").val( oldName )
          return

        App.user.updateToken( token, newTokenName ).fail ()->
          # If anything goes wrong, revert the name
          oldName = ""
          $p.children(".tokenName").val( oldName )
          notification "error", "Fail to update token, please retry."
        return

      confirmRmToken : ()->
        @modal.$("#TokenRemove").attr "disabled", "disabled"

        self = this
        App.user.removeToken( @rmToken ).then ()->
          self.updateTokenTab()
          self.cancelRmToken()
        , ()->
          notification "Fail to delete token, please retry."
          self.cancelRmToken()

        return

      cancelRmToken : ()->
        @rmToken = ""
        @modal.$("#TokenRemove").removeAttr "disabled"
        @modal.$("#TokenManager").show()
        @modal.$("#TokenRmConfirm").hide()
        return

      updateTokenTab : ()->
        tokens = App.user.get("tokens")
        @modal.$("#TokenManager").find(".token-table").toggleClass( "empty", tokens.length is 0 )
        if tokens.length
          @modal.$("#TokenList").html MC.template.accessTokenTable( tokens )
        else
          @modal.$("#TokenList").empty()
        return
    }

    SettingsDialog.TAB =
      CredentialInvalid : -1
      Normal            : 0
      Credential        : 1
      Token             : 2

    SettingsDialog
