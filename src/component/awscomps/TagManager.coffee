define [
    'constant',
    'CloudResources',
    "UI.modalplus",
    "component/awscomps/TagManagerTpl",
    "FilterInput",
    "backbone",
    'i18n!/nls/lang.js' ]
, ( constant, CloudResources, Modal, template, FilterInput, Backbone, lang) ->

  Backbone.View.extend {
    events:
      "click tbody tr.item" : "selectTableRow"
      "click .tag-resource-detail .tabs-navs li" : "switchTab"
      "click .create-tag" : "addTag"
      "change #t-m-select-all" : "selectAllInput"
      "change .tags-list input[type='text']": "changeTags"
      "click .delete-tag" : "removeTagUsage"

    initialize: (model)->
      @instance = Design.instance()
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

    compSnapshot: ()->
      instance = Design.instance()
      @snapshot = []
      self = @
      _.each instance.componentsOfType("AWS.EC2.Tag"), (tag)->
        self.snapshot.push _.clone tag, {}
      _.each instance.componentsOfType("AWS.AutoScaling.Tag"), (tag)->
        self.snapshot.push _.clone tag, {}
      console.log(@snapshot)

    recoverSnapshot: ()->
      # discard all change of tags components.
      self = @
      instance = Design.instance()
      currentTags = []
      _.each instance.componentsOfType("AWS.EC2.Tag"), (tag)->
        currentTags.push tag
      _.each instance.componentsOfType("AWS.AutoScaling.Tag"), (tag)->
        currentTags.push tag
      console.log currentTags

      oldTagIds = _.pluck @snapshot, "id"
      newTagIds = _.pluck currentTags, "id"

      removedTagIds = _.difference(oldTagIds, newTagIds)
      addedTagIds = _.difference(newTagIds, oldTagIds)
      changedTags = _.intersection(newTagIds, oldTagIds)

      _.each removedTagIds, (id)->
        # recover oldTags
        removedTag = _.findWhere self.snapshot, {id}
      _.each addedTagIds, (id)->
        addedTag = _.findWhere self.snapshot , {id}
        addedTag.remove()
      _.each changedTags, (id)->
        changedTag =  _.findWhere self.snapshot, {id}

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

    changeTags: (e)->
      $tagLi = $(e.currentTarget).parent()
      $tagKey = $tagLi.find(".tag-key")
      $tagValue = $tagLi.find(".tag-value")
      tagComp = @instance.component $tagLi.data("id")
      if $tagKey.val() and $tagValue.val()
        key = $tagKey.val()
        value = $tagValue.val()
        # Can't start with "aws:"
        if key.indexOf("aws:") == 0 then return false
        if tagComp
          tagComp.set({key,value})
        else
          error = null
          _.each @getAffectedResources(), (res)->
            err = res.addTag(key, value)
            if err
              error = true
          if error
            notification "error", "Sorry, but this key name is system retained."
          else
            @renderTagsContent()

    getAffectedResources :()->
      isSelected = "selected" is @$el.find(".tabs-navs li.active").data("id")
      resources = []
      if isSelected
        resources.push @instance.component @$el.find(".t-m-content .item.selected").data("id")
      else
        @$el.find(".t-m-content .one-cb").each (key, value)->
          if $(value).is(":checked")
            resources.push self.instance.component($(value).parents("tr").data("id"))
      resources

    removeTagUsage: (e)->
      $tagLi = $(e.currentTarget).parent()
      tagComp = @instance.component($tagLi.data("id"))
      if not tagComp
        $tagLi.remove()
        return
      resources = @getAffectedResources()
      _.each resources, (res)->
        res.removeTag(tagComp)
      @renderTagsContent()

    renderTagsContent: (uid)->
      self = @
      if not uid then uid = @$el.find(".t-m-content .item.selected").data("id")
      # selected tags
      selectedIsAsg = false
      checkedAllAsg = true
      selectedComp = @instance.component(uid)
      selectedIsAsg = selectedComp?.type is "AWS.AutoScaling.Group"
      tags = if selectedComp then selectedComp.tags() else []
      tagsData = _.map tags, (tag)->
        return {
          key: tag.get("key")
          value: tag.get("value")
          id: tag.id
          disableEdit: tag.get("retain")
          allowCheck: selectedIsAsg
        }
      @$el.find(".tab-content[data-id='selected']").html template.tagResource tagsData

      # checked Tags
      checkedData  = []
      checkedArray = []
      @$el.find(".t-m-content .one-cb").each (key, value)->
        checkedComp = self.instance.component($(value).parents("tr").data("id"))

        if checkedComp.type isnt "AWS.AutoScaling.Group"
          checkedAllAsg = false

        if $(value).is(":checked")
          checkedArray.push checkedComp.tags()

      checkedTagArray = _.map (checkedArray), (tagArray)->
        _.map tagArray, (tag)->
          tag.id
      checkedData = _.map _.intersection.apply(_, checkedTagArray), (tagId)->
        tag = self.instance.component(tagId)
        return {
          key: tag.get("key")
          value: tag.get("value")
          id: tag.id
          disableEdit: tag.get("retain")
          allowCheck: selectedIsAsg
        }

      @$el.find(".tab-content[data-id='checked']").html template.tagResource checkedData
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
      _.delay ()=> @renderTagsContent()

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

