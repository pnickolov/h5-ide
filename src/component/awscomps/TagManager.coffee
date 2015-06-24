define [ 'constant', 'CloudResources', "UI.modalplus", "component/awscomps/TagManagerTpl", "backbone", 'i18n!/nls/lang.js' ]
, ( constant, CloudResources, Modal, template, Backbone, lang) ->

  Backbone.View.extend {
    initialize: (model)->
      @model = model
      @renderModal()

    renderModal: ()->
      new Modal({
        title: "Tag Management"
        template: template.modalTemplate
      })
  }

