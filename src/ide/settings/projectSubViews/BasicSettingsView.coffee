define [ '../template/TplBasicSettings', 'UI.modalplus', 'backbone' ], ( TplBasicSettings, Modal ) ->

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
            else
                title = 'Leave Project'
                confirmText = 'Confirm to Leave'
                tpl = TplBasicSettings.confirmToLeave

            @$el.html tpl

            @modal = new Modal
                title: title
                template: @el
                confirm:
                    text: confirmText
                    disabled: true
                    color: 'red'

            @

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
            @$el.html TplBasicSettings.basicSettings @model.toJSON()
            @

        edit: ( e ) -> $( e.currentTarget ).closest( '.project-item' ).addClass 'edit'
        cancelEdit: ( e ) -> $( e.currentTarget ).closest( '.project-item' ).removeClass 'edit'

        updateName: ( e ) ->
            console.log 'update name'

        confirmDelete: ->
            @confirmModal?.remove()
            @confirmModal = new confirmModalView( projectName: "Paula's Project" ).render()
            @

        confirmLeave: ->
            @confirmModal?.remove()
            @confirmModal = new confirmModalView().render()
            @

        remove: ->
            @confirmModal?.remove()
            Backbone.View.prototype.remove.apply @, arguments










