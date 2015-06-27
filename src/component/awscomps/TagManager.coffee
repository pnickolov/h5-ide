define [ 'constant', 'CloudResources', "UI.modalplus", "component/awscomps/TagManagerTpl", "FilterInput", "backbone", 'i18n!/nls/lang.js' ]
, ( constant, CloudResources, Modal, template, FilterInput, Backbone, lang) ->

  Backbone.View.extend {
    events:
      "click tbody tr.item" : "selectTableRow"
      "click .tag-resource-detail .tabs-navs li" : "switchTab"
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
      @renderFilter()
      @modal

    renderFilter: ->
      filter = new FilterInput()
      @modal.tpl.find(".filter-bar").replaceWith(filter.render().el)
    selectTableRow: (evt)->
      $row = $(evt.currentTarget)
      @$el.find("tr.item").removeClass("selected")
      $row.addClass("selected")

    switchTab: (evt)->
      $li = $(evt.currentTarget)
      if $li.hasClass("active") then return false
      @$el.find(".tabs-navs li").removeClass("active")
      target = $li.addClass("active").data("id")
      @$el.find(".tabs-content .tab-content").hide()
      @$el.find(".tabs-content .tab-content[data-id='#{target}']").show()
  }

