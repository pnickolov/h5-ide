define [ "./FullnameTpl", "UI.modalplus", 'i18n!/nls/lang.js', "backbone" ], ( FullnameTpl, Modal, lang ) ->

  Backbone.View.extend {

    events:
      "click #submitFullName": "submit"

    initialize: (options)->
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
      @modal.setContent MC.template.loadingSpiner()
      window.setTimeout ->
        @modal.close()
        notification "info", lang.IDE.PROFILE_UPDATED_SUCCESSFULLY
      , 1000
  }