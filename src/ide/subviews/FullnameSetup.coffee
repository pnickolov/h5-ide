define [ "./FullnameTpl", "UI.modalplus", 'i18n!/nls/lang.js', 'ApiRequest', "backbone" ], ( FullnameTpl, Modal, lang, ApiRequest ) ->

  Backbone.View.extend {

    events:
      "click #submitFullName": "submit"
      "change #complete-firstname": "changeInput"
      "change #complete-lastname" : "changeInput"
      "keyup #complete-firstname" : "changeInput"
      "keyup #complete-lastname"  : "changeInput"

    initialize: ()->
      @modal = new Modal {
        title       : lang.IDE.COMPLETE_YOUR_PROFILE
        template    : FullnameTpl()
        width       : "600"
        disableClose: true
        hideClose   : true
        cancel      :
          hide: true
        confirm :
          disabled: true
      }
      @modal.on 'confirm', @submit.bind @
      @setElement @modal.tpl

    changeInput: ()->
      confirmBtn = @modal.find(".modal-confirm")
      $firstNameInput = @modal.find("#complete-firstname")
      $lastNameInput  = @modal.find("#complete-lastname")
      if !!$firstNameInput.val() and !!$lastNameInput.val()
        confirmBtn.attr("disabled", false)
      else
        confirmBtn.attr("disabled", true)

    submit: ()->
      that = @
      firstname = that.modal.$("#complete-firstname").val()
      lastname  = that.modal.$("#complete-lastname").val()
      if not (firstname and lastname)
        return false
      @modal.find(".modal-confirm").attr('disabled', true)
      @modal.setContent MC.template.loadingSpinner()
      ApiRequest("account_update_account", { attributes : {
        first_name : firstname
        last_name  : lastname
      }}).then  ->
        App.user.set("firstName", firstname)
        App.user.set("lastName" , lastname )
        that.modal.close()
        notification "info", lang.IDE.PROFILE_UPDATED_SUCCESSFULLY
      , ->
        that.modal.close()
        notification 'error', lang.IDE.PROFILE_UPDATED_FAILED
  }
