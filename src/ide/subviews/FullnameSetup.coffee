define [ "./FullnameTpl", "UI.modalplus", 'i18n!/nls/lang.js', 'ApiRequest', "backbone" ], ( FullnameTpl, Modal, lang, ApiRequest ) ->

  Backbone.View.extend {

    events:
      "click #submitFullName": "submit"

    initialize: ()->
      @modal = new Modal {
        title        : lang.IDE.COMPLETE_YOUR_PROFILE
        template     : FullnameTpl()
        width        : "600"
        disableClose : true
        hideClose    : true
        cancel       :
          hide: true
      }
      @modal.on 'confirm', @submit.bind @
      @setElement @modal.tpl

    submit: ()->
      that = @
      firstname = that.modal.$("#complete-firstname").val()
      lastname  = that.modal.$("#complete-lastname").val()
      if not (firstname and lastname)
        return false
      @modal.find(".modal-confirm").attr('disabled', true)
      @modal.setContent MC.template.loadingSpiner()
      ApiRequest("account_update_account", { attributes : {
        first_name : firstname
        last_name  : lastname
      }}).then  ->
        App.user.set("first_name", firstname)
        App.user.set("last_name" , lastname )
        @modal.close()
        notification "info", lang.IDE.PROFILE_UPDATED_SUCCESSFULLY
      , ->
        @modal.close()
        notification 'error', lang.IDE.PROFILE_UPDATED_FAILED
  }