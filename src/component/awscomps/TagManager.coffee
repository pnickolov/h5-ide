define [ 'constant', 'CloudResources', "UI.modalplus", "component/awscomps/TagManagerTpl", "backbone", 'i18n!/nls/lang.js' ]
, ( constant, CloudResources, Modal, template, Backbone, lang) ->

  Backbone.View.extend {
    events:
      "click tbody tr.item" : "selectTableRow"
    initialize: (model)->
      @model = model
      @setElement @renderModal().tpl
      @

    renderModal: ()->
      @modal = new Modal({
        title: "Tag Management"
        width: 800
        height: 300
        template: template.modalTemplate
      })
      @modal

    selectTableRow: (evt)->
      $row = $(evt.currentTarget)
      @$el.find("tr.item").removeClass("selected")
      $row.addClass("selected")
  }

