define [
    'i18n!/nls/lang.js'
    '../template/TplBasicSettings'
    'UI.modalplus'
    '../models/MemberCollection'
    'UI.notification'
    'backbone'
], ( lang, TplBasicSettings, Modal, MemberCollection ) ->

    Backbone.View.extend
        events:
            'click .edit-button'        : 'edit'
            'click .cancel-button'      : 'cancelEdit'
            'click #update-name'        : 'updateName'
            'click #delete-project'     : 'confirmDelete'
            'click #leave-project'      : 'confirmLeave'
            'keyup #project-name'       : 'checkName'

            'keyup #confirm-project-name' : 'confirmProjectName'
            'paste #confirm-project-name' : 'deferConfirmProjectName'
            'click #do-delete-project'    : 'doDelete'
            'click #do-leave-project'     : 'doLeave'
            'click .cancel-leave-confirm' : 'cancelLeaveConfirm'
            'click .cancel-delete-confirm': 'cancelDeleteConfirm'

        className: 'basic-settings'

        initialize: ( options ) ->
            _.extend @, options
            @memberCol = new MemberCollection({projectId: @model.id})
            @listenTo @model, 'change:name', @changeNameOnView

        getRenderData: ->
            data = @model.toJSON()
            data.isAdmin = @model.amIAdmin()
            data.isMember = @model.amIMeber()
            data.isObserver = @model.amIObserver()
            data.failedToPay = @model.shouldPay()

            data

        render: () ->
            data = @getRenderData()
            @$el.html TplBasicSettings.basicSettings data
            @renderLeaveZone data
            @renderDeleteZone(data) if data.isAdmin
            @

        renderLeaveZone: ( data = @getRenderData(), confirm = false ) ->
            if confirm
                tpl = TplBasicSettings.confirmToLeave
            else
                tpl = TplBasicSettings.leave
            @$( '.leave-project-zone' ).html tpl data
            @

        renderDeleteZone: ( data = @getRenderData(), confirm = false ) ->
            if confirm
                tpl = TplBasicSettings.confirmToDelete
            else
                tpl = TplBasicSettings.delete
            @$( '.delete-project-zone' ).html tpl data
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
                that.settingsView.modal.close()
            , ->
                that.render()
                notification 'error', lang.IDE.SETTINGS_ERR_PROJECT_REMOVE
        doLeave: ->

            that = @
            that.renderLoading()

            # not admin, directly leave
            if not that.model.amIAdmin()
                that.toLeave()

            # is admin, check if unique
            else
                that.memberCol.fetch().then () ->
                    currentMember = that.memberCol.getCurrentMember()
                    if currentMember.isAdmin()
                        if not currentMember.isOnlyAdmin()
                            that.toLeave()
                        else
                            that.render()
                            notification 'error', lang.IDE.LEAVING_WORKSPACE_WILL_ONLY_ONE_ADMIN
                            # that.$el.find('.level-error-tip').removeClass('hide')
                    else
                        that.toLeave()
                .fail (data) ->
                    that.render()
                    notification 'error', (data.result or data.msg)

        toLeave: ->

            that = @
            that.model.leave().then ->
                that.remove()
                that.settingsView.modal.close()
            , ->
                that.render()
                notification 'error', lang.IDE.SETTINGS_ERR_PROJECT_LEAVE

        confirmLeave: -> @renderLeaveZone null, true
        cancelLeaveConfirm: -> @renderLeaveZone()
        confirmDelete: -> @renderDeleteZone null, true
        cancelDeleteConfirm: -> @renderDeleteZone()
