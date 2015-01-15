define [ 'i18n!/nls/lang.js', 'UI.modalplus', './ProjectView', './template/TplSettings', 'backbone' ], ( lang, Modal, ProjectView, TplSettings ) ->
    SettingsView = Backbone.View.extend {
        events:
            'click .project-list a': 'loadProject'
            'click .back-settings': 'renderSettings'

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
            @$el.html TplSettings
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
            Member: "Member"
            ProviderCredential: 'ProviderCredential'
            UsageReport: 'UsageReport'


    SettingsView