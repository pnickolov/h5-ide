define [
    'constant'
    'i18n!/nls/lang.js'
    '../template/TplCredential'
    'UI.modalplus'
    'UI.tooltip'
    'UI.notification'
    'backbone'
], ( constant, lang, TplCredential, Modal ) ->

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

            @modal.on 'confirm', ->
                @trigger 'confirm'
            , @

            @

        remove: ->
            @modal?.close()
            Backbone.View.prototype.remove.apply @, arguments

        updateSubmitBtn : ()->
            d = @getData()

            if d.alias.length and d.account.length and d.accesskey.length and d.privatekey.length
                @modal.toggleConfirm false
            else
                @modal.toggleConfirm true
            return

        getData: ->
            that = @

            alias      : that.$( '#CredSetupAlias' ).val()
            account    : that.$( '#CredSetupAccount' ).val()
            accesskey  : that.$( '#CredSetupAccessKey' ).val()
            privatekey : that.$( '#CredSetupSecretKey' ).val()




    Backbone.View.extend
        events:
            'click .setup-credential': 'showSetForm'
            'click .update-link'     : 'showUpdateForm'
            'click .show-button-list': 'showButtonList'
            'click .delete-link'     : 'showRemoveConfirmModel'

        className: 'credential'

        render: () ->
            data = @model.toJSON()
            data.credentials = _.map @model.credentials(), ( c ) ->
                json = c.toJSON()
                json.name = constant.PROVIDER_NAME[json.provider]
                json

            @$el.html TplCredential.credentialManagement data
            @

        showButtonList: ->
            @$( '.button-list' ).toggle()
            false

        getCredentialById: ( id ) -> _.findWhere @model.credentials(), { id: id }

        showSetForm: -> @showSettingModal()

        showUpdateForm: ( e ) ->
            credentialId = $( e.currentTarget ).data 'id'
            credential = @getCredentialById credentialId
            @showSettingModal credential

        addCredential: ( provider, credential ) ->

        updateCredential: ( credential, newData ) ->

        removeCredential: ( credential ) ->
            @removeConfirmView.setContent TplCredential.credentialLoading { action: 'Remove' }
            credential.destroy().then () ->
                @removeConfirmView?.close()
            , ( error ) ->
                @removeConfirmView.setContent TplCredential.removeConfirm
                @removeConfirm.find( '#CredDeletepMsg' ).text lang.IDE.SETTINGS_ERR_CRED_REMOVE

        showUpdateConfirmModel: ->
            @updateConfirmView?.close()
            @updateConfirmView = new Modal {
                title: 'Update Cloud Credential'
                template: TplCredential.removeConfirm
                confirm:
                    text: 'Confirm to Update'
            }
            @updateConfirmView.on 'confirm', updateCredential, @

        showRemoveConfirmModel: ->
            credentialId = $( e.currentTarget ).data 'id'
            credential = @getCredentialById credentialId

            @removeConfirmView?.close()
            @removeConfirmView = new Modal {
                title: 'Delete Cloud Credential'
                template: TplCredential.removeConfirm
                confirm:
                    text: 'Remove Credential'
            }

            @removeConfirmView.on 'confirm', () -> @removeCredential credential

        showSettingModal:( credential, provider ) ->
            @settingModalView = new credentialFormView( provider:provider ).render credential
            @settingModalView.on 'confirm', ->
                if credential
                    @updateCredential credential, @showSettingModal.getData()
                else
                    @addCredential null, @showSettingModal.getData()
            @

        remove: ->
            @settingModalView?.remove()
            @updateConfirmView?.close()
            @removeConfirmView?.close()
            Backbone.View.prototype.remove.apply @, arguments

