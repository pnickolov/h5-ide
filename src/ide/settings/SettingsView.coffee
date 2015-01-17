define [
    'i18n!/nls/lang.js'
    'UI.modalplus'
    './ProjectView'
    './template/TplSettings'

    'backbone'
], ( lang, Modal, ProjectView, TplSettings ) ->
    SettingsView = Backbone.View.extend {
        events:
            'click .project-list a': 'loadProject'
            'click .back-settings': 'renderSettings'

            'click #AccountEmail'             : 'showEmail'
            'click #AccountFullName'          : 'showFullName'
            'click #AccountPwd'               : 'showPwd'
            'click #AccountCancelPwd'         : 'hidePwd'
            'click #AccountUpdatePwd'         : 'changePwd'

        showEmail : ()->
            @hideFullName()
            $(".accountEmailRO").hide()
            $("#AccountEmailWrap").show()
            $("#AccountNewEmail").focus()
            return

        showFullName: ()->
            @hideEmail()
            $(".accountFullNameRO").hide()
            $("#AccountFullNameWrap").show()
            $("#AccountFirstName").val(App.user.get("firstName") || "").focus()
            $("#AccountLastName").val(App.user.get("lastName") || "")
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
        changePwd : ()->
            that = @
            old_pwd = @modal.$("#AccountCurrentPwd").val() || ""
            new_pwd = @modal.$("#AccountNewPwd").val() || ""
            if new_pwd.length < 6
                @modal.$('#AccountInfo').text lang.IDE.SETTINGS_ERR_INVALID_PWD
                return

            @modal.$("#AccountInfo").empty()

            @modal.$("#AccountUpdatePwd").attr "disabled", "disabled"

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

        className: 'fullpage-settings'

        initialize: ( options ) ->
            if options
                @tab = options.tab
                @projectId = options.projectId

            @render(@tab)


        render: ( tab = SettingsView.TAB.Account ) ->
            that = @
            if tab is SettingsView.TAB.Account
                @renderSettings()
            else
                @renderProject projectId, tab

            @modal = new Modal
                template: that.el
                mode: 'fullscreen'
                disableFooter: true
                compact: true
            @

        renderSettings: () ->
            data = _.extend {}, App.user.toJSON()
            data.gravatar = App.user.gravatar()

            @$el.html TplSettings data
            @

        loadProject: ( e ) ->
            projectId = $(e.currentTarget).data 'id'
            @renderProject projectId

        renderProject: ( projectId, tab ) ->
            @$el.html new ProjectView().render(tab).el

        remove: ->
            @model and @model.close()
            Backbone.View.prototype.remove.apply arguments





    }

    SettingsView.TAB =
        Account: 'Account'
        Project:
            BasicSettings: 'BasicSettings'
            AccessToken: 'AccessToken'
            Billing: 'Billing'
            Member: 'Member'
            ProviderCredential: 'ProviderCredential'
            UsageReport: 'UsageReport'


    SettingsView