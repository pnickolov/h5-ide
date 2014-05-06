#############################
#  View(UI logic) for dialog
#############################

define [ "./SettingsDialogTpl", 'i18n!nls/lang.js', "backbone" ], ( SettingsTpl, lang ) ->

    SettingsDialog = Backbone.View.extend {

      events :
        "click #SettingsNav span" : "switchTab"
        "click #AccountPwd"       : "showPwd"
        "click #AccountCancelPwd" : "hidePwd"
        "click #AccountUpdatePwd" : "changePwd"
        "click .cred-setup"       : "showCredSetup"
        "click #CredSetupCancel"  : "cancelCredSetup"

      initialize : ( options )->

        attributes =
          username     : App.user.get("username")
          email        : App.user.get("email")
          account      : App.user.get("account")
          awsAccessKey : App.user.get("awsAccessKey")
          awsSecretKey : App.user.get("awsSecretKey")

        modal SettingsTpl attributes
        @setElement $("#modal-box")

        defaultTab = 0
        if options then defaultTab = options.defaultTab || 0
        $("#SettingsNav").children().eq( defaultTab ).click()
        return

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
          $('#account-passowrd-info').text lang.ide.HEAD_MSG_ERR_INVALID_PASSWORD
          return

        $("#account-passowrd-info").empty()

        $("#AccountUpdatePwd").attr "disabled", "disabled"

        App.user.changePassword( old_pwd, new_pwd ).then ()->
          notification 'info', lang.ide.HEAD_MSG_INFO_UPDATE_PASSWORD
          $("#AccountCancelPwd").click()
          $("#AccountUpdatePwd").removeAttr "disabled"
          return
        , ( err )->
          if err.error is 2
            $('#account-passowrd-info').html "#{lang.ide.HEAD_MSG_ERR_WRONG_PASSWORD} <a href='/reset/' target='_blank'>#{lang.ide.HEAD_MSG_INFO_FORGET_PASSWORD}</a>"
          else
            $('#account-passowrd-info').text lang.ide.HEAD_MSG_ERR_UPDATE_PASSWORD

          $("#AccountUpdatePwd").removeAttr "disabled"

        return

      showCredSetup : ()->
        $("#CredDemoWrap, #CredAwsWrap").hide()
        $("#CredSetupWrap").show()
        $("#CredSetupAccount").focus()[0].select()
        return

      cancelCredSetup : ()->
        $("#CredSetupWrap").hide()
        if App.user.hasCredential()
          $("#CredAwsWrap").show()
        else
          $("#CredDemoWrap").show()
        return
    }

    SettingsDialog.TAB =
      Normal     : 0
      Credential : 1

    SettingsDialog
