define [ '../template/TplCredential', 'UI.modalplus', 'UI.tooltip', 'backbone' ], ( TplCredential, Modal ) ->

    credentialFormView = Backbone.View.extend
        events:
            'keyup  #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey' : 'updateSubmitBtn'

        render: ( credential ) ->

            if credential
                title = 'Update Cloud Credential'
                confirmText = 'Update'
            else
                credential = {}
                title = 'Add Cloud Credential'
                confirmText = 'Add'

            @$el.html TplCredential.credentialForm credential

            @modal = new Modal
                title: title
                template: @el
                confirm:
                    text: confirmText
                    disabled: true

            @

        remove: ->
            @modal?.close()
            Backbone.View.prototype.remove.apply @, arguments

        updateSubmitBtn : ()->
            alias      = @$( 'CredSetupAlias' ).val()
            account    = @$( '#CredSetupAccount' ).val()
            accesskey  = @$( '#CredSetupAccessKey' ).val()
            privatekey = @$( '#CredSetupSecretKey' ).val()

            if account.length and accesskey.length and privatekey.length
                @modal.toggleConfirm false
            else
                @modal.toggleConfirm true
            return



    Backbone.View.extend
        events:
            'click .setup-credential': 'setCredential'
            'click .show-button-list': 'showButtonList'

        className: 'credential'

        render: () ->
            @$el.html TplCredential.credentialManagement
            @

        showButtonList: ->
            @$( '.button-list' ).toggle()
            false

        updateCredential: ->

        setCredential: ->
            @showSettingModal()

        showSettingModal:(credential) ->
            @settingModalView = new credentialFormView().render credential
            @

        remove: ->
            @settingModalView?.remove()
            Backbone.View.prototype.remove.apply @, arguments