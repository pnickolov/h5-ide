define [
    'constant',
    'CloudResources',
    "UI.modalplus",
    "component/awscomps/TagManagerTpl",
    "FilterInput",
    "backbone",
    'i18n!/nls/lang.js'
    'event'
    ]
, ( constant, CloudResources, Modal, template, FilterInput, Backbone, lang, ide_event) ->

  Backbone.View.extend {
    events:
      "click .create-tag"       : "addTag"
      "click .edit-delete"      : "removeTagUsage"
      "click .edit-done"        : "changeTags"
      "click .save-tags"        : "saveAllTags"
      "click .edit-remove-row"  : "removeRow"
      "click .edit-tags"        : "editTags"
      "click .cancel"           : "cancelEdit"
      "keyup .tag-key.input"    : "changeTagInput"
      "keyup .tag-value.input"  : "changeTagInput"
      "change #t-m-select-all"  : "selectAllInput"
      "change .tag-resource-list .checkbox input"  : "selectInput"
      "click .t-m-content tr.item" : "clickItem"

    initialize: (model)->
      @instance = Design.instance()
      @model = model
      @setElement @renderModal().tpl
      @renderFilter()
      @

    renderModal: ()->
      @modal = new Modal({
        title: "Tag Management"
        width: 900
        height: 500
        template: template.modalTemplate
        disableFooter: true
        disableClose: true
      })
      @modal

    renderFilter: ->
      data = if @model then {uid: @model.id} else null
      @filter = new FilterInput(data)
      @listenTo @filter, 'change:filter', @filterResourceList
      @modal.tpl.find(".filter-bar").replaceWith(@filter.render().el)
      if data
        @filterResourceList @filter.getMatchedResource()
        @$el.find(".t-m-content tr.item:first-child").find('input').prop('checked', true)
      else
        @filterResourceList @filter.getFilterableResource()

    selectAllInput: (e)->
      isChecked = $(e.currentTarget).is(":checked")
      @$el.find(".table-head-fix .item .checkbox input").prop("checked", isChecked)
      @renderTagsContent()

    selectInput: () ->
      @renderTagsContent()

    clickItem: (e) ->
      unless $(e.target).parents(".checkbox").size() > 0
        $(e.currentTarget).find('.checkbox input').click()

    editTags  : (e) -> @$('.tag-resource-detail').addClass 'show'
    cancelEdit: (e) -> @$('.tag-resource-detail').removeClass 'show'

    changeTags: (elem)->
      $tagLi = $(elem).parents("li")
      $tagKey = $tagLi.find(".tag-key")
      $tagValue = $tagLi.find(".tag-value")
      tagComp = @instance.component $tagLi.data("id")
      tagAsgComp = @instance.component $tagLi.data("asg")

      if $tagKey.val()
        key = $tagKey.val()
        value = $tagValue.val()
        inherit = $tagLi.find(".checkbox input").is(":checked")
        # Can't start with "aws:"
        if key.indexOf("aws:") == 0 then return false
        resource = @getAffectedResources()
        if tagComp
          tagComp.update(resource.common, key, value)
        if tagAsgComp
          tagAsgComp.update(resource.asg, key, value, inherit)

        if not tagComp and not tagAsgComp
          error = null
          _.each _.union(resource.common, resource.asg), (res)->
            err = res.addTag(key, value, inherit)
            if err
              error = err
          if error
            # todo
            notification "error", error.error
      else
        # todo:
        notification "error", "Sorry, both key and value are required."

    saveAllTags: ()->
      that = @
      @$el.find(".tab-content:visible").find("input.tag-key").not(":disabled").each (index, value)->
        if value.value then that.changeTags(value)
      @renderTagsContent()
      @cancelEdit()
      ide_event.trigger ide_event.REFRESH_PROPERTY

    getAffectedResources :()->
        self = @
        resources = {common: [], asg: []}
        @$el.find(".t-m-content .one-cb").each (key, value)->
          if $(value).is(":checked")
            comp =  self.instance.component($(value).parents("tr").data("id"))
            if comp.type is "AWS.AutoScaling.Group"
              resources.asg.push comp
            else
              resources.common.push comp
        resources

    removeTagUsage: (e)->
      $tagLi = $(e.currentTarget).parents("li")
      tagComp = @instance.component($tagLi.data("id"))
      asgTagComp = @instance.component($tagLi.data("asg"))
      resources = @getAffectedResources()
      if not tagComp and not asgTagComp
        $tagLi.remove()
        return

      if tagComp
        _.each resources.common, (res)->
          res.removeTag(tagComp)
      if asgTagComp
        _.each resources.asg, (asg)->
          asg.removeTag(asgTagComp)
      @renderTagsContent()

    renderTagsContent: (uid)->
      self = @
      if not uid then uid = @$el.find(".t-m-content .item.selected").data("id")
      checkedAllAsg = true
      # checked Tags
      checkedComps = []
      checkedTagArray = []
      checkedAsgComps = []
      checkedAsgTagArray = []
      @$el.find(".t-m-content .one-cb").each (key, value)->
        checkedComp = self.instance.component($(value).parents("tr").data("id"))
        if checkedComp.type isnt "AWS.AutoScaling.Group"
          checkedAllAsg = false
          if $(value).is(":checked")
            checkedComps.push checkedComp
            checkedTagArray.push checkedComp.tags()
        else
          if $(value).is(":checked")
            checkedAsgComps.push checkedComp
            checkedAsgTagArray.push checkedComp.tags()

      checkedTagIdsArray = _.map (checkedTagArray), (tagArray)->
        _.map tagArray, (tag)->
          tag.id
      checkedData = _.map _.intersection.apply(_, checkedTagIdsArray), (tagId)->
        tag = self.instance.component(tagId)
        return {
          key: tag.get("key")
          value: tag.get("value")
          id: tag.id
          disableEdit: tag.get("retain")
          allowCheck: checkedAllAsg
        }

      checkedAsgTagIdsArray = _.map checkedAsgTagArray, (tagArray)->
        _.map tagArray, (tag)->
          tag.id

      # asg tags in common data
      checkedAsgData = _.map _.intersection.apply(_, checkedAsgTagIdsArray), (tagId)->
        tag = self.instance.component(tagId)
        return {
          key: tag.get("key")
          value: tag.get("value")
          inherit: tag.get("inherit")
          asg: tag.id
          disableEdit: tag.get("retain")
          allowCheck: checkedAllAsg
        }

      # both in common comps and asg comps
      unitedData = []
      if checkedAsgComps.length
        if checkedComps.length
          unitedData = _.compact _.map checkedData, (data)->
            commonData = _.findWhere checkedAsgData, {key:data.key, value:data.value}
            if commonData
              commonData.id = data.id
            commonData
        else
          unitedData = checkedAsgData
      else
        unitedData = checkedData

      allComps = checkedComps.concat(checkedAsgComps)
      @$el.find(".tab-content[data-id='checked']").html template.tagResource {data: unitedData, empty: not allComps.length, allAsg: checkedAllAsg}
      info = allComps.length
      if allComps.length == 1
        info = allComps[0].get('name')
      @$el.find(".tabs-navs span").text("(#{info})")
      @changeTagInput()

    filterResourceList: (resModels)->
      models = _.map resModels, (model)->
        return {
          name: model.get("name")
          appId : model.get("appId")
          type : model.type
          id : model.id
        }
      @modal.tpl.find(".t-m-content").html(template.filterResource {models: models})
      if models.length is 1
        @$el.find(".t-m-content tr.item:first-child").find('input').prop('checked', true)
      _.delay ()=> @renderTagsContent()

    changeTagInput: () ->

        focusToLast = false
        @$el.find(".tags-list li").each (idx, elem) ->
            if not $(elem).find('.input.tag-key').val() and not $(elem).find('.input.tag-value').val()
                focusToLast = true if $(@).next('li').length
                $(@).remove()
            else
                $(elem).find('.edit-remove-row').show()
        @addTag()
        if focusToLast
          @$el.find(".tags-list li:last-child .input.tag-key").focus()

    addTag: (e)->
      tagId = @$el.find(".tags-list li").size() + 1
      tagTemplate = """
          <li class="edit">
              <div class="edit">
                  <input class="tag-key input" type="text" value="" maxlength="127" data-ignore="true" data-required-rollback="true"/>
                  <input class="tag-value input" type="text" value="" maxlength="255" data-ignore="true" data-required-rollback="true"/>
                  <div class="checkbox">
                      <input id='#{tagId}' type="checkbox" value="None" class="one-cb">
                      <label for="#{tagId}"></label>
                  </div>
                  <div class="action">
                    <button class="btn btn-red edit-remove-row"><i class="icon-del"></i></button>
                  </div>
              </div>
          </li>
      """
      $tagLi = $(tagTemplate)
      $tagLi.appendTo @$el.find("ul.tags-list")
      hasNoneAsg = @getAffectedResources().common.length > 0
      if hasNoneAsg
        $tagLi.find(".checkbox").remove().end().find(".action").addClass("wide")

    removeRow: (e)->
      $(e.currentTarget).parents("li").remove()
  }
