define [ 'constant', 'CloudResources', "UI.modalplus", "component/awscomps/TagManagerTpl", "FilterInput", "backbone", 'i18n!/nls/lang.js' ]
, ( constant, CloudResources, Modal, template, FilterInput, Backbone, lang) ->

  Backbone.View.extend {
    events:
      "click tbody tr.item" : "selectTableRow"
      "click .tag-resource-detail .tabs-navs li" : "switchTab"
      "click .create-tag" : "addTag"
      "change #t-m-select-all" : "selectAllInput"

    initialize: (model)->
      @model = model
      @setElement @renderModal().tpl
      @

    renderModal: ()->
      @modal = new Modal({
        title: "Tag Management"
        width: 900
        height: 400
        template: template.modalTemplate
      })
      @renderFilter()
      @modal

    renderFilter: ->
      @filter = new FilterInput()
      @listenTo @filter, 'change:filter', @filterResourceList
      @modal.tpl.find(".filter-bar").replaceWith(@filter.render().el)
      @filterResourceList @filter.getFilterableResource()

    selectTableRow: (evt)->
      $row = $(evt.currentTarget)
      @$el.find("tr.item").removeClass("selected")
      $row.addClass("selected")
      @$el.find(".tabs-navs ul li[data-id='selected']").click()
      # reder selected element
      @renderTagsContent($row.data("id"))

    renderTagsContent: (uid)->
      # selected tags
      instance = Design.instance()
      selectedIsAsg = false
      checkedAllAsg = true
      selectedComp = instance.component(uid)
      selectedIsAsg = selectedComp.type is "AWS.AutoScaling.Group"
      tags = selectedComp.tags()
      tagsData = _.map tags, (tag)->
        return {
          key: tag.get("key")
          value: tag.get("value")
          id: tag.id
          allowCheck: selectedIsAsg
        }
      @$el.find(".tab-content[data-id='selected']").find("ul.tags-list").html template.tagResource tagsData

      # checked Tags
      checkedData  = []
      checkedArray = []
      @$el.find(".t-m-content .one-cb").each (key, value)->
        checkedComp = instance.component($(value).parents("tr").data("id"))

        if checkedComp.type isnt "AWS.AutoScaling.Group"
          checkedAllAsg = false

        if $(value).is(":checked")
          checkedArray.push checkedComp.tags()

      checkedTagArray = _.map (checkedArray), (tagArray)->
        _.map tagArray, (tag)->
          tag.id
      checkedData = _.map _.intersection.apply(_, checkedTagArray), (tagId)->
        tag = instance.component(tagId)
        return {
          key: tag.get("key")
          value: tag.get("value")
          id: tag.id
          allowCheck: selectedIsAsg
        }
      console.log checkedData

      @$el.find(".tab-content[data-id='checked']").find("ul.tags-list").html template.tagResource checkedData
      @$el.find(".tabs-navs li[data-id='checked'] span").text(checkedData.length or 0)

    filterResourceList: (resModels)->
      models = _.map resModels, (model)->
        return {
          name: model.get("name")
          appId : model.get("appId")
          type : model.type
          id : model.id
        }
      @modal.tpl.find(".t-m-content").html(template.filterResource {models: models})

    selectAllInput: (e)->
      isChecked = $(e.currentTarget).is(":checked")
      @$el.find(".table-head-fix .item .checkbox input").prop("checked", isChecked)

    addTag: (e)->
      tagId = @$el.find(".tags-list li").size() + 1
      tagTemplate = """
        <li>
          <input class="tag-key input" type="text"/>
          <input class="tag-value input" type="text"/>
          <div class="checkbox">
            <input id="tag-#{tagId}" type="checkbox" class="one-cb">
            <label for="tag-#{tagId}"></label>
          </div>
          <div class="delete-tag"></div>
        </li>
      """
      $(e.currentTarget).parents(".tab-content").find("ul.tags-list").append(tagTemplate)

    switchTab: (evt)->
      $li = $(evt.currentTarget)
      if $li.hasClass("active") then return false
      @$el.find(".tabs-navs li").removeClass("active")
      target = $li.addClass("active").data("id")
      @$el.find(".tabs-content .tab-content").hide()
      @$el.find(".tabs-content .tab-content[data-id='#{target}']").show()
  }

