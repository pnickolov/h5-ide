define [
    'i18n!/nls/lang.js'
    'UI.modalplus'
    './ProjectSettings'
    './template/TplSettings'

    'backbone'
], ( lang, Modal, ProjectView, TplSettings ) ->
    SettingsView = Backbone.View.extend {
        events:
            'click .project-list a': 'renderProject'
            'click .back-settings': 'backToSettings'

            'click #AccountEmail'             : 'showEmail'
            'click #AccountFullName'          : 'showFullName'
            'click #AccountPwd'               : 'showPwd'
            'click #AccountCancelPwd'         : 'hidePwd'
            'click #AccountUpdatePwd'         : 'changePwd'

            'click #AccountCancelEmail'                 : 'hideEmail'
            'click #AccountUpdateEmail'                 : 'changeEmail'
            'click #AccountCancelFullName'              : 'hideFullName'
            'change #AccountNewEmail, #AccountEmailPwd' : 'updateEmailBtn'
            'keyup  #AccountNewEmail, #AccountEmailPwd' : 'updateEmailBtn'
            'click #AccountUpdateFullName'              : 'changeFullName'
            'change #AccountFirstName, #AccountLastName': 'updateFullNameBtn'
            'keyup #AccountFirstName, #AccountLastName' : 'updateFullNameBtn'

            'change #AccountCurrentPwd, #AccountNewPwd' : 'updatePwdBtn'
            'keyup  #AccountCurrentPwd, #AccountNewPwd' : 'updatePwdBtn'

        className: 'fullpage-settings'

        initialize: ( attr, options ) ->
            if attr
                @projectId = attr.projectId
                tab = attr.tab?.toLowerCase()
                if @projectId and not tab then tab = SettingsView.TAB.Project.BasicSettings

            @scene = options.scene

            @projects = App.model.projects()
            @render(tab)


        render: ( tab = SettingsView.TAB.Account ) ->
            that = @
            if tab is SettingsView.TAB.Account
                renderResult = @renderSettings()
            else
                renderResult = @renderProject @projects.get( @projectId ), tab

            unless renderResult then return false

            @modal = new Modal
                template: that.el
                mode: 'fullscreen'
                disableFooter: true
                compact: true
            @modal.on "close", -> that.scene.remove()
            @

        renderSettings: () ->
            data = _.extend {}, App.user.toJSON()
            data.gravatar = App.user.gravatar()
            data.projects = @projects.toJSON()

            @$el.html TplSettings data
            @

        backToSettings: ->
            @navigate()
            @renderSettings()

        backToDefaultProject: ->
            @modal.close()
            privateProject = App.model.getPrivateProject()
            Router.navigate "/workspace/#{privateProject.id}", trigger: true

        renderProject: ( project, tab ) ->
            console.log "SettingsView"
            if project and project.currentTarget # Load by dom event
                projectId = $(project.currentTarget).data 'id'
                project = @projects.get projectId

                @navigate SettingsView.TAB.Project.BasicSettings, projectId
            else # Load by url
                if ( !project ) or ( tab not in _.values SettingsView.TAB.Project ) or ( !@auth project, tab )
                    notification 'error', lang.IDE.PAGE_NOT_FOUND_WORKSPACE_TAB_NOT_EXIST
                    Router.navigate '/', trigger: true
                    return false

            @projectView?.remove()
            @projectView = new ProjectView( model: project, settingsView: @ )
            @$el.html @projectView.render(tab).el

        remove: ->
            @projectView?.remove()
            @modal?.close()
            Backbone.View.prototype.remove.apply @, arguments

        navigate: ( tab, projectId ) ->
            url = @url tab, projectId
            Router.navigate url

        url: ( tab, projectId ) ->
            unless tab then return '/settings'
            return "/settings/#{projectId}/#{tab}"

        auth: ( project, tab ) ->
            project.amIAdmin() or tab not in [ SettingsView.TAB.Project.Billing, SettingsView.TAB.Project.ProviderCredential ]

        # Account Operation

        showEmail : ()->
            @hideFullName()
            $(".accountEmailRO").hide()
            $("#AccountEmailWrap").show()
            $("#AccountNewEmail").focus()
            return

        hideEmail : ()->
            $(".accountEmailRO").show()
            $("#AccountEmailWrap").hide()
            $("#AccountNewEmail, #AccountEmailPwd").val("")
            $("#SettingErrorInfo").empty()
            return

        showFullName: ()->
            @hideEmail()
            $(".accountFullNameRO").hide()
            $("#AccountFullNameWrap").show()
            $("#AccountFirstName").val(App.user.get("firstName") || "").focus()
            $("#AccountLastName").val(App.user.get("lastName") || "")
            return

        hideFullName: ()->
            $(".accountFullNameRO").show()
            $("#AccountFullNameWrap").hide()
            $("#AccountFirstName, #AccountLastName").val("")
            $("#AccountUpdateFullName").attr("disabled", false)

        showPwd : ()->
            @$("#AccountPwd").hide()
            @$("#AccountPwdWrap").show()
            @$("#AccountCurrentPwd").focus()
            return

        hidePwd : ()->
            @$("#AccountPwd").show()
            @$("#AccountPwdWrap").hide()
            @$("#AccountCurrentPwd, #AccountNewPwd").val("")
            @$("#AccountInfo").empty()
            return

        updatePwdBtn : ()->
            old_pwd = @$("#AccountCurrentPwd").val() || ""
            new_pwd = @$("#AccountNewPwd").val() || ""

            if old_pwd.length and new_pwd.length
                @$("#AccountUpdatePwd").removeAttr "disabled"
            else
                @$("#AccountUpdatePwd").attr "disabled", "disabled"

            return

        updateEmailBtn : ()->
            new_email = $("#AccountNewEmail").val() || ""
            new_pwd = $("#AccountEmailPwd").val() || ""

            regExp = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i
            isValidEmail = regExp.test new_email
            if new_email.length and new_pwd.length >= 6 and isValidEmail
                $("#AccountUpdateEmail").removeAttr "disabled"
                $("#SettingErrorInfo").text("")
            else
                if not isValidEmail
                  $("#SettingErrorInfo").text(lang.IDE.SETTING_INVALID_EMAIL)
                else
                  $("#SettingErrorInfo").text("")
                $("#AccountUpdateEmail").attr "disabled", "disabled"
            return

        updateFullNameBtn: ()->
            first_name = $("#AccountFirstName").val() || ""
            last_name  = $("#AccountLastName").val()  || ""

            if first_name.length and last_name.length
                $("#AccountUpdateFullName").removeAttr "disabled"
            else
                $("#AccountUpdateFullName").attr "disabled", "disabled"
            return

        changeFullName: ()->
            that = @
            first_name = $("#AccountFirstName").val() || ""
            last_name  = $("#AccountLastName").val()  || ""

            if first_name and last_name
                $("#AccountUpdateFullName").attr("disabled", true)
                App.user.changeName( first_name, last_name ).then (result)->
                    that.hideFullName()
                    $(".fullNameText").text(first_name + " " + last_name)
                    if result
                      notification "info", lang.NOTIFY.UPDATED_FULLNAME_SUCCESS
                , (err)->
                    notification "error", lang.NOTIFY.UPDATED_FULLNAME_FAIL
                    $("#AccountUpdateFullName").attr("disabled", false)
                    console.error("Change Full name Failed due to ->", err)

        changeEmail : ()->
            email = $("#AccountNewEmail").val() || ""
            pwd   = $("#AccountEmailPwd").val() || ""

            $("#SettingErrorInfo").empty()
            $("#AccountUpdateEmail").attr "disabled", "disabled"

            App.user.changeEmail( email, pwd ).then ()->
                notification 'info', lang.NOTIFY.SETTINGS_UPDATE_EMAIL_SUCCESS
                $("#AccountCancelEmail").click()
                $(".accountEmailRO").find(".email-view").text( App.user.get("email") )
                return
            , ( err )->
                switch err.error
                    when 116
                        text = lang.IDE.SETTINGS_UPDATE_EMAIL_FAIL3
                    when 117
                        text = lang.IDE.SETTINGS_UPDATE_EMAIL_FAIL2
                    else
                        text = lang.IDE.SETTINGS_UPDATE_EMAIL_FAIL1

                $('#SettingErrorInfo').text text
                $("#AccountUpdateEmail").removeAttr "disabled"
            return

        changePwd : ()->
            that = @
            old_pwd = @$("#AccountCurrentPwd").val() || ""
            new_pwd = @$("#AccountNewPwd").val() || ""
            if new_pwd.length < 6
                @$('#AccountInfo').text lang.IDE.SETTINGS_ERR_INVALID_PWD
                return

            @$("#AccountInfo").empty()

            @$("#AccountUpdatePwd").attr "disabled", "disabled"

            App.user.changePassword( old_pwd, new_pwd ).then ()->
                notification 'info', lang.NOTIFY.SETTINGS_UPDATE_PWD_SUCCESS
                $("#AccountCancelPwd").click()
                return
            , ( err )->
                if err.error is 2
                    that.modal.$('#AccountInfo').html "#{lang.IDE.SETTINGS_ERR_WRONG_PWD} <a href='/reset/' target='_blank'>#{lang.IDE.SETTINGS_INFO_FORGET_PWD}</a>"
                else
                    that.modal.$('#AccountInfo').text lang.IDE.SETTINGS_UPDATE_PWD_FAILURE

                that.modal.$("#AccountUpdatePwd").removeAttr "disabled"

            return


    }

    SettingsView.TAB =
        Account: 'account'
        Project:
            BasicSettings: 'basicsettings'
            AccessToken: 'accesstoken'
            Billing: 'billing'
            Team: 'team'
            ProviderCredential: 'credential'
            UsageReport: 'usagereport'


    SettingsView
