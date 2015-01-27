define [
    'constant'
    'i18n!/nls/lang.js'
    '../template/TplCredential'
    'Credential'
    'ApiRequest'
    'UI.modalplus'
    'UI.tooltip'
    'UI.notification'
    'backbone'
], ( constant, lang, TplCredential, Credential, ApiRequest, Modal ) ->

    credentialFormView = Backbone.View.extend
        events:
            'keyup  #CredSetupAccount, #CredSetupAccessKey, #CredSetupSecretKey' : 'updateSubmitBtn'

        render: ( credential ) ->
            if credential
                data = credential.toJSON()
                title = 'Update Cloud Credential'
                confirmText = 'Update'
            else
                data = {}
                title = 'Add Cloud Credential'
                confirmText = 'Add'

            @$el.html TplCredential.credentialForm data

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

        loading: ->
            @$( '#CredSetupWrap' ).hide()
            @$el.append( TplCredential.credentialLoading { action: 'Add' } )
            @modal.$el.find( '.modal-footer' ).hide()

        loadingEnd: ->
            @$('.loading-zone').remove()
            @$( '#CredSetupWrap' ).show()
            @modal.$el.find( '.modal-footer' ).show()

        remove: ->
            @modal?.close()
            Backbone.View.prototype.remove.apply @, arguments

        updateSubmitBtn : ()->
            d = @getData()

            if d.alias.length and d.awsAccount.length and d.awsAccessKey.length and d.awsSecretKey.length
                @modal.toggleConfirm false
            else
                @modal.toggleConfirm true
            return

        getData: ->
            that = @

            alias         : that.$( '#CredSetupAlias' ).val()
            awsAccount    : that.$( '#CredSetupAccount' ).val()
            awsAccessKey  : that.$( '#CredSetupAccessKey' ).val()
            awsSecretKey  : that.$( '#CredSetupSecretKey' ).val()




    Backbone.View.extend
        events:
            'click .setup-credential': 'showSetForm'
            'click .update-link'     : 'showUpdateForm'
            'click .show-button-list': 'showButtonList'
            'click .delete-link'     : 'showRemoveConfirmModel'

        className: 'credential'

        initialize: ->
            @listenTo @model, 'change:credentials', @render

        render: () ->
            data = @model.toJSON()
            data.isAdmin = @model.amIAdmin()
            data.credentials = _.map @model.credentials(), ( c ) ->
                json = c.toJSON()
                json.isAdmin = data.isAdmin
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

        addCredential: ( data ) ->
            that = @
            credentialData = {
                alias : data.alias
                account_id: data.awsAccount
                access_key: data.awsAccessKey
                secret_key: data.awsSecretKey
            }
            credentialData.provider = data.provider or constant.PROVIDER.AWSGLOBAL

            credential = new Credential credentialData, { project: @model }

            @settingModalView.loading()
            credential.save().then () ->
                that.settingModalView.remove()
            , ( error ) ->
                if error.error is ApiRequest.Errors.UserInvalidCredentia
                    msg = lang.IDE.SETTINGS_ERR_CRED_VALIDATE
                else
                    msg = lang.IDE.SETTINGS_ERR_CRED_UPDATE

                that.settingModalView.loadingEnd()
                that.settingModalView.$( '.cred-setup-msg' ).text msg


        updateCredential: ( credential, newData ) ->
            that = @
            @updateConfirmView.setContent TplCredential.credentialLoading { action: 'Update' }

            credential.save( newData ).then () ->
                that.updateConfirmView.close()
                that.settingModalView.remove()
            , ( error ) ->
                that.updateConfirmView.setContent TplCredential.removeConfirm
                if error.error is ApiRequest.Errors.UserInvalidCredentia
                    msg = lang.IDE.SETTINGS_ERR_CRED_VALIDATE
                else
                    msg = lang.IDE.SETTINGS_ERR_CRED_UPDATE
                that.updateConfirmView.find( '.cred-setup-msg' ).text msg

        removeCredential: ( credential ) ->
            that = @
            @removeConfirmView.setContent TplCredential.credentialLoading { action: 'Remove' }

            credential.destroy().then () ->
                that.removeConfirmView?.close()
            , ( error ) ->
                that.removeConfirmView.setContent TplCredential.removeConfirm
                that.removeConfirm.find( '.cred-setup-msg' ).text lang.IDE.SETTINGS_ERR_CRED_REMOVE

        showUpdateConfirmModel: ( credential, newData ) ->
            @updateConfirmView?.close()
            @updateConfirmView = new Modal {
                title: 'Update Cloud Credential'
                template: TplCredential.removeConfirm
                confirm:
                    text: 'Confirm to Update'
            }
            @updateConfirmView.on 'confirm', ->
                @updateCredential credential, newData
            , @

        showRemoveConfirmModel: ( e ) ->
            credentialId = $( e.currentTarget ).data 'id'
            credential = @getCredentialById credentialId

            @removeConfirmView?.close()
            @removeConfirmView = new Modal {
                title: 'Delete Cloud Credential'
                template: TplCredential.removeConfirm
                confirm:
                    text: 'Remove Credential'
            }

            @removeConfirmView.on 'confirm', () ->
                @removeCredential credential
            , @

        showSettingModal:( credential, provider ) ->
            @settingModalView = new credentialFormView( provider:provider ).render credential
            @settingModalView.on 'confirm', ->
                if credential
                    @showUpdateConfirmModel credential, @settingModalView.getData()
                else
                    @addCredential @settingModalView.getData()
            , @

            @

        remove: ->
            @settingModalView?.remove()
            @updateConfirmView?.close()
            @removeConfirmView?.close()
            Backbone.View.prototype.remove.apply @, arguments

