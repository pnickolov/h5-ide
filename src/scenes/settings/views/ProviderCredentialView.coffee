define [
    'constant'
    'i18n!/nls/lang.js'
    '../template/TplCredential'
    'Credential'
    'ApiRequest'
    'UI.modalplus'
    "credentialFormView"
    'UI.tooltip'
    'UI.notification'
    'backbone'
], ( constant, lang, TplCredential, Credential, ApiRequest, Modal, credentialFormView ) ->

    credentiaLoadingTips =
        add     : lang.IDE.SETTINGS_CRED_ADDING
        update  : lang.IDE.SETTINGS_CRED_UPDATING
        remove  : lang.IDE.SETTINGS_CRED_REMOVING

    Backbone.View.extend
        events:
            'click .setup-credential': 'showAddForm'
            'click .update-link'     : 'showUpdateForm'
            'click .show-button-list': 'showButtonList'
            'click .delete-link'     : 'showRemoveConfirmModel'

        className: 'credential'

        initialize: ->
            @listenTo @model, 'update:credential', @render
            @listenTo @model, 'change:credential', @render

        render: () ->
            credentials = @model.credentials().models

            data = @model.toJSON()
            data.isAdmin = @model.amIAdmin()

            # Only support provider aws::global for now.
            # so if a non-demo credential exsit, the user can not add another credential then.

            # Only admin can add, update or remove credential
            if data.isAdmin
                if credentials.length is 0
                    data.addable = true
                else
                    data.addable = not _.some credentials, ( cred ) ->
                        not cred.isDemo()

            applist = @model.apps()

            data.credentials = _.map credentials, ( c ) ->
                json = c.toJSON()
                json.isAdmin = data.isAdmin
                json.name = constant.PROVIDER_NAME[json.provider]
                json.needed = applist.some ( app ) -> app?.get( 'provider' ) is json.provider

                if json.isDemo then data.hasDemo = true

                json


            @$el.html TplCredential.credentialManagement data
            @

        showButtonList: ->
            @$( '.button-list' ).toggle()
            false

        getCredentialById: ( id ) -> @model.credentials().findWhere { id: id }

        makeModalLoading: ( modal, action ) ->
            modal
                .setContent( TplCredential.credentialLoading { tip: credentiaLoadingTips[ action ] } )
                .toggleFooter false
            @

        stopModalLoading: ( modal, originContent ) ->
            modal
                .setContent( originContent )
                .toggleFooter true
            @

        showModalError: ( modal, message ) -> modal.$( '.cred-setup-msg' ).text message

        showAddForm: -> @showFormModal()

        showUpdateForm: ( e ) ->
            credentialId = $( e.currentTarget ).data 'id'
            credential = @getCredentialById credentialId
            @showFormModal credential

        removeCredential: ( credential ) ->
            that = @
            @makeModalLoading @removeConfirmView, 'Remove'

            credential.destroy().then () ->
                that.removeConfirmView?.close()
            , ( error ) ->
                credName = constant.PROVIDER_NAME[credential.get 'provider']
                that.stopModalLoading that.removeConfirmView, TplCredential.removeConfirm name: credName
                that.showModalError that.removeConfirmView, lang.IDE.SETTINGS_ERR_CRED_REMOVE

        showUpdateConfirmModel: ( credential, newData ) ->
            @updateConfirmView?.close()
            @updateConfirmView = new Modal {
                title: 'Update Cloud Credential'
                template: TplCredential.updateConfirm
                confirm:
                    text: 'Confirm to Update'
                    color: 'red'
            }

            @updateConfirmView.on 'confirm', ->
                @updateCredential credential, newData, true
            , @

        showRemoveConfirmModel: ( e ) ->
            credentialId = $( e.currentTarget ).data 'id'
            credential = @getCredentialById credentialId
            credName = constant.PROVIDER_NAME[credential.get 'provider']

            @removeConfirmView?.close()
            @removeConfirmView = new Modal {
                title: 'Delete Cloud Credential'
                template: TplCredential.removeConfirm name: credName
                confirm:
                    text: 'Remove Credential'
            }

            @removeConfirmView.on 'confirm', () ->
                @removeCredential credential
            , @

        showFormModal:( credential, provider ) ->
            @formView = new credentialFormView( provider:provider, credential: credential, model: @model ).render()
            @

        remove: ->
            @formView?.remove()
            @updateConfirmView?.close()
            @removeConfirmView?.close()
            Backbone.View.prototype.remove.apply @, arguments

