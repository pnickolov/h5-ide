define [
    'i18n!/nls/lang.js'
    '../template/TplBasicSettings'
    'UI.modalplus'
    'UI.notification'
    'backbone'
], ( lang, TplBasicSettings, Modal ) ->

    confirmModalView = Backbone.View.extend
        events:
            'keyup  #confirm-project-name' : 'confirmProjectName'

        initialize: ( options ) ->
            if options and options.projectName then @projectName = options.projectName

        render: ->
            if @projectName
                title = 'Delete Project'
                confirmText = 'Confirm to Delete'
                tpl = TplBasicSettings.confirmToDelete
                confirmDisabled = true
            else
                title = 'Leave Project'
                confirmText = 'Confirm to Leave'
                tpl = TplBasicSettings.confirmToLeave
                confirmDisabled = false

            @$el.html tpl

            if @model then return @

            @modal = new Modal
                title: title
                template: @el
                confirm:
                    text: confirmText
                    disabled: confirmDisabled
                    color: 'red'

            @modal.on 'confirm', ->
                @trigger 'confirm'
            , @

            @

        renderLoading: -> @$el.html TplBasicSettings.loading

        confirmProjectName: ( e ) ->
            if e.currentTarget.value is @projectName
                 @modal.toggleConfirm false
            else
                @modal.toggleConfirm true


        remove: ->
            @modal?.close()
            Backbone.View.prototype.remove.apply @, arguments

    Backbone.View.extend
        events:
            'click .edit-button'        : 'edit'
            'click .cancel-button'      : 'cancelEdit'
            'click #update-name'        : 'updateName'
            'click #delete-project'     : 'confirmDelete'
            'click #leave-project'      : 'confirmLeave'

        className: 'basic-settings'

        render: () ->
            data = @model.toJSON()
            data.isAdmin = @model.amIAdmin()
            data.isMember = @model.amIMeber()
            data.isObserver = @model.amIObserver()

            if @model.isPrivate() or @model.amIAdmin()
                data.displayDelete = true
            else
                data.displayDelete = false

            @$el.html TplBasicSettings.basicSettings data
            @

        edit: ( e ) -> $( e.currentTarget ).closest( '.project-item' ).addClass 'edit'
        cancelEdit: ( e ) -> $( e.currentTarget ).closest( '.project-item' ).removeClass 'edit'

        updateName: ( e ) ->
            console.log 'update name'

        confirmDelete: ->
            @confirmModal?.remove()
            @confirmModal = new confirmModalView( projectName: @model.get( 'name' ) ).render()
            @confirmModal.on 'confirm', ->
                @confirmModal.renderLoading()
                @model.destroy().then =>
                    @remove()
                    @settingsView.remove()
                , =>
                    notification 'error', lang.IDE.SETTINGS_ERR_PROJECT_REMOVE
                    @confirmModal.render()
            , @

            @

        confirmLeave: ->
            @confirmModal?.remove()
            @confirmModal = new confirmModalView().render()
            @confirmModal.on 'confirm', =>
                @confirmModal.renderLoading()
                @model.leave().then ->
                    @remove()
                    @settingsView.remove()
                , =>
                    notification 'error', lang.IDE.SETTINGS_ERR_PROJECT_LEAVE
                    @confirmModal.render()
            , @

            @

        remove: ->
            @confirmModal?.remove()
            Backbone.View.prototype.remove.apply @, arguments












