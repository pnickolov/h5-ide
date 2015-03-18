define [
  "constant"
  "ApiRequest"
  'Credential'
  'UI.modalplus'
  'i18n!/nls/lang.js'
  'backbone'
], ( constant, ApiRequest, Credential, Modal, lang ) ->

  credentialLoadingTips =
    add     : lang.IDE.SETTINGS_CRED_ADDING
    update  : lang.IDE.SETTINGS_CRED_UPDATING
    remove  : lang.IDE.SETTINGS_CRED_REMOVING

  credentialFormView = Backbone.View.extend
    events:
      'keyup input' : 'updateSubmitBtn'
      'paste input' : 'deferUpdateSubmitBtn'

    initialize: ( options ) ->
      _.extend @, options

    render: ->
      if @credential
        data = @credential.toJSON()
        title = lang.IDE.UPDATE_CLOUD_CREDENTIAL
        confirmText = lang.IDE.HEAD_BTN_UPDATE
      else
        data = {}
        title = lang.IDE.ADD_CLOUD_CREDENTIAL
        confirmText = lang.IDE.CFM_BTN_ADD

      @$el.html MC.template.credentialForm data

      @modal = new Modal
        title: title
        template: @el
        width: 480
        confirm:
          text: confirmText
          disabled: true

      @modal.on 'confirm', ->
        if @credential
          @updateCredential()
        else
          @addCredential()
        @trigger 'confirm'
      , @

      @

    loading: ->
      @$( '#CredSetupWrap' ).hide()
      action =  if @credential then 'Update' else 'Add'
      @$el.append( MC.template.credentialLoading { tip: credentialLoadingTips[ action ] } )
      @modal.toggleFooter false

    loadingEnd: ->
      @$('.loading-zone').remove()
      @$( '#CredSetupWrap' ).show()
      @modal.toggleFooter true

    remove: ->
      @updateConfirmView?.close()
      @modal?.close()
      Backbone.View.prototype.remove.apply @, arguments

    deferUpdateSubmitBtn: ( e ) -> _.defer _.bind @updateSubmitBtn, @, e

    updateSubmitBtn : ()->
      d = @getData()

      if d.alias.length and d.awsAccount.length and d.awsAccessKey.length and d.awsSecretKey.length
        @modal.toggleConfirm false
      else
        @modal.toggleConfirm true
      return

    addCredential: ->
      that = @
      data = @getData()
      # Temporary
      provider = Credential.PROVIDER.AWSGLOBAL

      # Find credential has same provider, only update the credential, not add
      credential = @model.credentials().findWhere provider: provider

      if credential
        credential.set data, silent: true
      else # no credential has same provider, add a new credential
        credentialData = {
          alias : data.alias
          account_id: data.awsAccount
          access_key: data.awsAccessKey
          secret_key: data.awsSecretKey
        }
        credentialData.provider = data.provider or Credential.PROVIDER.AWSGLOBAL
        credential = new Credential credentialData, { project: @model }
      @loading()
      credential.save().then () ->
        that.remove()
      , ( error ) ->
        if error.error is ApiRequest.Errors.UserInvalidCredentia
          msg = lang.IDE.SETTINGS_ERR_CRED_VALIDATE
        else
          msg = lang.IDE.SETTINGS_ERR_CRED_UPDATE

        that.loadingEnd()
        that.showModalError msg

    showUpdateConfirmModel: () ->
        @updateConfirmView?.close()
        @updateConfirmView = new Modal {
            title: lang.IDE.UPDATE_CLOUD_CREDENTIAL
            template: MC.template.updateCredentialConfirm
            confirm:
                text: lang.IDE.SETTINGS_LABEL_UPDATE_CONFIRM
                color: 'red'
        }

        @updateConfirmView.on 'confirm', ->
            @updateCredential(true)
            @updateConfirmView.close()
        , @

    updateCredential: (forceUpdate = false) ->
      that = @
      if not @credential then return false
      @loading()
      newData = @getData()
      @credential.save( newData, forceUpdate, true ).then () ->
        that.updateConfirmView?.close()
        that.remove()
      , ( error ) ->
        that.loadingEnd()

        if error.error is ApiRequest.Errors.UserInvalidCredentia
          msg = lang.IDE.SETTINGS_ERR_CRED_VALIDATE
        else if error.error is ApiRequest.Errors.ChangeCredConfirm
          that.hideModalError()
          that.showUpdateConfirmModel()
        else
          msg = lang.IDE.SETTINGS_ERR_CRED_UPDATE

        msg and that.showModalError msg

    showModalError: ( message ) ->

        @$el.find( '.cred-setup-msg' ).show().html message

    hideModalError: () ->

        @$el.find( '.cred-setup-msg' ).hide()

    getData: ->
      that = @

      alias         : that.$( '#CredSetupAlias' ).val()
      awsAccount    : that.$( '#CredSetupAccount' ).val()
      awsAccessKey  : that.$( '#CredSetupAccessKey' ).val()
      awsSecretKey  : that.$( '#CredSetupSecretKey' ).val()




  credentialFormView
