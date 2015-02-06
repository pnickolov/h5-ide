define [
    'i18n!/nls/lang.js'
    '../template/TplBasicSettings'
    'UI.modalplus'
    'UI.notification'
    'backbone'
], ( lang, TplBasicSettings, Modal ) ->

    Backbone.View.extend
        events:
            'click .edit-button'        : 'edit'
            'click .cancel-button'      : 'cancelEdit'
            'click #update-name'        : 'updateName'
            'click #delete-project'     : 'confirmLeaveDelete'
            'click #leave-project'      : 'confirmLeaveDelete'
            'keyup #project-name'       : 'checkName'

            'keyup #confirm-project-name' : 'confirmProjectName'
            'paste #confirm-project-name' : 'deferConfirmProjectName'
            'click #do-delete-project'    : 'doDelete'
            'click #do-leave-project'     : 'doLeave'

        className: 'basic-settings'

        initialize: ( options ) ->
            _.extend @, options
            @listenTo @model, 'change:name', @changeNameOnView

        getRenderData: ->
            data = @model.toJSON()
            data.isAdmin = @model.amIAdmin()
            data.isMember = @model.amIMeber()
            data.isObserver = @model.amIObserver()

            if @model.isPrivate() or @model.amIAdmin()
                data.displayDelete = true
            else
                data.displayDelete = false

            data

        render: () ->
            data = @getRenderData()
            @$el.html TplBasicSettings.basicSettings data
            @renderLeaveZone data
            @

        renderLeaveZone: ( data = @getRenderData(), confirm = false ) ->
            if confirm
                if data.isAdmin
                    tpl = TplBasicSettings.confirmToDelete
                else
                    tpl = TplBasicSettings.confirmToLeave
            else
                tpl = TplBasicSettings.leaveOrDelete

            @$( '.leave-project-zone' ).html tpl data
            @

        renderLoading: ->
            @$el.html TplBasicSettings.loading

        deferConfirmProjectName: ( e ) -> _.defer _.bind @confirmProjectName, @, e

        confirmProjectName: ( e ) ->
            if e.currentTarget.value is @model.get( 'name' )
                 @$( '#do-delete-project' ).prop 'disabled', false
            else
                 @$( '#do-delete-project' ).prop 'disabled', true

        edit: ( e ) -> $( e.currentTarget ).closest( '.project-item' ).addClass 'edit'
        cancelEdit: ( e ) -> $( e.currentTarget ).closest( '.project-item' ).removeClass 'edit'

        checkName: ( e ) ->
            $updateBtn = @$ '#update-name'
            if e.currentTarget.value.length > 0
                $updateBtn.prop 'disabled', false
            else
                $updateBtn.prop 'disabled', true

        updateName: ( e ) ->
            that = @
            newName = @$( '#project-name' ).val()

            @updateNameLoading e
            @model.updateName( newName ).then ->
                that.updateNameLoading e, true
                that.cancelEdit e
            , ->
                that.updateNameLoading e, true
                notification 'error', lang.IDE.SETTINGS_ERR_PROJECT_RENAME

        changeNameOnView: -> @$( '.project-name' ).text @model.get 'name'

        updateNameLoading: ( e, stop = false ) ->
            $projectItem = $( e.currentTarget ).closest( '.project-item' )
            $editZone = $projectItem.find '.edit-actions'
            $loadingZone = $projectItem.find '.loading-spinner'

            $editZone.toggle stop
            $loadingZone.toggle !stop

        doDelete: ->
            that = @
            @renderLoading()

            @model.destroy().then ->
                that.remove()
                that.settingsView.backToSettings()
            , ->
                that.render()
                notification 'error', lang.IDE.SETTINGS_ERR_PROJECT_REMOVE
        doLeave: ->
            that = @
            @renderLoading()

            @model.leave().then ->
                that.remove()
                that.settingsView.backToSettings()
            , ->
                that.render()
                notification 'error', lang.IDE.SETTINGS_ERR_PROJECT_LEAVE

        confirmLeaveDelete: -> @renderLeaveZone null, true








