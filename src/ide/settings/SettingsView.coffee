define [ 'i18n!/nls/lang.js', 'UI.modalplus', './ProjectView', './template/TplSettings', 'backbone' ], ( lang, Modal, ProjectView, TplSettings ) ->
    SettingsView = Backbone.View.extend {
        events:
            'click .project-list a': 'loadProject'

        className: 'fullpage-settings'

        initialize: ( options ) ->
            @render()


        render: (renderSettings = true) ->
            that = @
            @renderSettings()
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

        renderProject: ( projectId) ->
            #@$el.html new ProjectView( model: projectModel ).render().el
            console.error 'TODO'

        renderRight: () ->

        remove: ->
            @model and @model.close()
            Backbone.View.prototype.remove.apply arguments


    }

    SettingsView.TAB =
        CredentialInvalid : -1
        Normal            : 0
        Credential        : 1
        Token             : 2

    SettingsView