#############################
#  View(UI logic) for dialog
#############################

define [ "./SettingsDialogTpl", 'i18n!nls/lang.js', "ApiRequest", "backbone" ], ( SettingsTpl, lang, ApiRequest ) ->

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

        "keyup #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey" : "updateSubmitBtn"

      initialize : ( options )->

        attributes =
          username     : App.user.get("username")
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

          credRemoveTitle : sprintf lang.ide.SETTINGS_CRED_REMOVE_TIT, App.user.get("username")
          credNeeded : !!(_.reduce _.map(MC.data.app_list, (el)-> el.length), ((m,n)->m+n), 0)

        modal SettingsTpl attributes
        @setElement $("#modal-box")

        defaultTab = 0
        if options then defaultTab = options.defaultTab || 0
        $("#SettingsNav").children().eq( defaultTab ).click()

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
        $("#AccountInfo").empty()
        return

      changePwd : ()->
        old_pwd = $("#AccountCurrentPwd").val() || ""
        new_pwd = $("#AccountNewPwd").val() || ""
        if old_pwd.length < 6 or new_pwd.length < 6
          $('#AccountInfo').text lang.ide.SETTINGS_ERR_INVALID_PWD
          return

        $("#AccountInfo").empty()

        $("#AccountUpdatePwd").attr "disabled", "disabled"

        App.user.changePassword( old_pwd, new_pwd ).then ()->
          notification 'info', lang.ide.SETTINGS_UPDATE_PWD_SUCCESS
          $("#AccountCancelPwd").click()
          $("#AccountUpdatePwd").removeAttr "disabled"
          return
        , ( err )->
          if err.error is 2
            $('#AccountInfo').html "#{lang.ide.SETTINGS_ERR_WRONG_PWD} <a href='/reset/' target='_blank'>#{lang.ide.SETTINGS_INFO_FORGET_PWD}</a>"
          else
            $('#AccountInfo').text lang.ide.SETTINGS_UPDATE_PWD_FAILURE

          $("#AccountUpdatePwd").removeAttr "disabled"

        return

      showCredSetup : ()->
        $("#CredentialTab").children().hide()
        $("#CredSetupWrap").show()
        $("#CredSetupAccount").focus()[0].select()
        $("#CredSetupRemove").toggle App.user.hasCredential()
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
          self.updateCredSettings()
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
          self.setCred()
          return
        , ()->
          $("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_VALIDATE
          $("#modal-box .modal-close").show()
          self.showCredSetup()
          return

      setCred : ()->
        account    = $("#CredSetupAccount").val()
        accesskey  = $("#CredSetupAccessKey").val()
        privatekey = $("#CredSetupSecretKey").val()

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
        $("#CredSetupMsg").text lang.ide.SETTINGS_ERR_CRED_UPDATE
        $("#modal-box .modal-close").show()
        @showCredSetup()

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
        $("#TokenManager").hide()
        $("#TokenRmConfirm").show()
        $("#TokenRmTit").text( sprintf lang.ide.SETTINGS_CONFIRM_TOKEN_RM_TIT, name )
        return

      createToken : ()->
        $("#TokenCreate").attr "disabled", "disabled"

        self = this
        Q.defer().promise.then ()->
          self.updateTokenTab()
          $("#TokenCreate").removeAttr "disabled"
        , ()->
          $("#TokenCreate").removeAttr "disabled"

        return

      doneEditToken : ( evt )->
        $p = $(evt.currentTarget).closest("li").removeClass("editing")
        $p.children(".tokenName").attr "readonly", true

        Q.defer().promise.then ()->
          # Do nothing if update success
          return
        , ()->
          # If anything goes wrong, revert the name
          oldName = ""
          $p.children(".tokenName").val( oldName )
        return

      confirmRmToken : ()->
        $("#TokenRemove").attr "disabled", "disabled"

        self = this
        Q.defer().promise.then ()->
          self.updateTokenTab()
          self.cancelRmToken()
        , ()->
          notification "Fail to delete access token, please retry."

        return

      cancelRmToken : ()->
        @rmToken = ""
        $("#TokenManager").show()
        $("#TokenRmConfirm").hide()
        return

      updateTokenTab : ()->
        tokens = [{name:"Token1",token:"aaabbbccc"},{name:"Token2",token:"bbbdddccc"}]
        if tokens.length
          $("#TokenManager").children("ul").html MC.template.accessTokenTable( tokens )
        else
          $("#TokenManager").empty()
        return
    }

    SettingsDialog.TAB =
      Normal     : 0
      Credential : 1
      Token      : 2

    SettingsDialog
