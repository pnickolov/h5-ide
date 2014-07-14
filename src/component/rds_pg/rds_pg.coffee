define ['CloudResources', 'ApiRequest', 'constant', "UI.modalplus", 'combo_dropdown', 'toolbar_modal', "i18n!/nls/lang.js", 'component/rds_pg/template'], (CloudResources, ApiRequest , constant, modalPlus, combo_dropdown, toolbar_modal, lang, template)->
  fetched = false
  deleteCount = 0
  deleteErrorCount = 0
  fetching = false
  regionsMark = {}
  DbpgRes = Backbone.View.extend
    constructor: (model)->
      if model then @resModel = model
      @collection = CloudResources constant.RESTYPE.DBPG, Design.instance().region()
      @listenTo @collection, 'update', (@onUpdate.bind @)
      @listenTo @collection, 'change', (@onUpdate.bind @)
      @

    onUpdate: ->
      @initManager()
      @trigger 'datachange', @

    remove: ()->
      Backbone.View::remove.call @

    render: ()->
      @renderManager()

    enableCreate: ->
      @manager.$el.find('[data-action="create"]').prop 'disabled', false

    selectRegion: ->
      @manager.$el.find('[data-action="reset"]').prop 'disabled', false

    renderManager: ()->
      @manager = new toolbar_modal @getModalOptions()
      @manager.on 'refresh', @refresh, @
      @manager.on "slidedown", @renderSlides, @
      @manager.on 'action', @doAction, @
      @manager.on 'close', =>
        @manager.remove()
        @collection.remove()
      @manager.on 'checked', @processReset, @

      @manager.render()
      if not App.user.hasCredential()
        @manager?.render 'nocredential'
        return false
      @initManager()


    initManager: ()->
      setContent = @setContent.bind @
      currentRegion = Design.instance().get('region')
      if (not fetched and not fetching) or (not regionsMark[currentRegion])
        fetching = true
        regionsMark[currentRegion] = true
        @collection.fetchForce().then setContent, setContent
      else if not fetching
        @setContent()


    processReset: ( event, checked ) ->
      if checked.length is 1 and not @collection.findWhere( id: checked[0].data.id ).isDefault()
        @M$('[data-btn=reset],[data-btn=edit]').prop 'disabled', false
      else
        @M$('[data-btn=reset],[data-btn=edit]').prop 'disabled', true
      that = @
      allNotDefault = _.every checked, (e)->
        val =  not that.collection.findWhere(id: e.data.id).isDefault()
        return val
      if checked.length >= 1 and allNotDefault
        window.setTimeout ->
          that.M$('[data-btn=delete]').prop 'disabled', false
        ,1
      else
        window.setTimeout ->
          that.M$('[data-btn=delete]').prop 'disabled', true
        ,1


    refresh: ->
      fetched = false
      @initManager()

    setContent: ->
      fetching = false
      fetched = true
      data = @collection.toJSON()
      dataSet =
        items: data
      content = template.content dataSet
      @manager?.setContent content


    renderSlides: (which, checked)->
      tpl = template['slide_'+ which]
      $(".slidebox .content").removeAttr('style')
      slides = @getSlides()
      slides[which]?.call @, tpl, checked
#      if(which == "create")
#        $(".slidebox").css("height": "100%")
#      else
#        $(".slidebox").removeAttr("style")



    getSlides: ->
      'delete': (tpl, checked)->
        checkedAmount = checked.length
        if not checkedAmount
          return
        data = {}
        if checkedAmount is 1
          data.selectedId = checked[0].data.id
        else
          data.selectedCount = checkedAmount
        @manager.setSlide tpl data
      'create':(tpl)->
        @families = CloudResources constant.RESTYPE.DBENGINE, Design.instance().get("region")
        that = @
        @families.fetch().then ->
            families = _.uniq _.pluck that.families.toJSON(), "DBParameterGroupFamily"
            data = families: families
            that.manager.setSlide tpl data
            $("#property-dbpg-name-create").keyup ()->
              disableCreate = not $(@).val()
              that.manager.$el.find('[data-action="create"]').prop 'disabled', disableCreate

      'edit': (tpl, checked, option)->
        if not checked then return false
        that = @
        target = @collection.findWhere(id: checked[0].data.id)
        parameters = target.getParameters()
        if not option then that.manager.setSlide template.loading()
        parameters.fetch().then (result)->
          if result.error
            that.manager.cancel()
            notification 'error', (result.awsResult||result.msg)
          that.renderEditTpl(parameters, tpl, option)
          $(".slidebox .content").css(
            "width": "100%"
            "margin-top": "0px"
          )
          that.bindEditEvent(parameters, tpl, option)

      'reset': (tpl, checked)->
        data = name: checked[0].data.id
        if not checked
          return
        @manager.setSlide tpl data

    renderEditTpl: (parameters, tpl, option)->
      that = @
      data = if parameters.toJSON then parameters.toJSON() else parameters
      _.each data, (e)->
        if e.AllowedValues?.split(',').length > 1
          e.inputType = "select"
          e.selections = e.AllowedValues.split(",")
          return
        else
          e.inputType = "input"
          return
      if option?.sort
        data = _.sortBy data, (e)->
          s = e.ParameterName
          if option.sort is "ParameterName"
            s = e.ParameterName
          if option.sort is 'IsModifiable'
            s = e.IsModifiable
          if option.sort is "ApplyType"
            s = e.ApplyType
          if option.sort is "Source"
            s = e.Source
          return s
        $("#parameter-table").html template.filter {data:data}
      if option?.filter
        data = _.filter data, (e)->
          (e.ParameterName.toLowerCase().indexOf option.filter.toLowerCase()) > -1
        $("#parameter-table").html template.filter {data:data}
      if option?.filter or option?.sort then return false
      that.manager.setSlide tpl data:data

    bindFilter: (parameters, tpl)->
      that = @
      sortType = $("#sort-parameter-name").find(".item.selected")?.data()?.id
      filter = $("#pg-filter-parameter-name")
      filter.off('change').on 'change', ->
        val = $(@).val()
        checked = [
          data:
            id: parameters.groupModel.id
        ]
        (that.getSlides().edit.bind that) template.slide_edit, checked, {filter: val,sort: sortType}
      $("#sort-parameter-name").on 'OPTION_CHANGE', (event, value, data)->
        sortType = data?.id || value
        filter.trigger 'change'

    bindEditEvent: (parameters,tpl, option)->
      that = @
      getChange = ->
        changeArray = []
        parameters.filter (e)->
          if e.has('newValue') and (e.get("newValue") isnt e.get("ParameterValue"))
            changeArray.push e.toJSON()
        changeArray
      if getChange().length then $("[data-action='preview']").prop 'disabled', false
      unless option then that.bindFilter(parameters, tpl)
      unless option then $("#pg-filter-parameter-name").keyup ->
        $(@).trigger 'change'
      _.each parameters.models, (e)->
        onChange = ->
          $("[data-action='preview']").prop 'disabled', false
          if this.value is "<engine-default>" or (this.value is "" and not e.get("ParameterValue"))
            e.unset('newValue')
          if e.isValidValue(this.value) or this.value is ""
            $(this).removeClass "parsley-error"
            if this.value isnt "" then e.set('newValue', this.value)
          else
            $(this).addClass "parsley-error"

        if e.attributes.IsModifiable
          $(".slidebox").on 'change',"[name='"+e.attributes.ParameterName+"']", onChange
          $(".slidebox").on 'keyup',"[name='"+e.attributes.ParameterName+"']", onChange

      unless option then $("[data-action='preview']").click ->
        data = getChange()
        _.each data, (e)->
          if e.AllowedValues?.split(',').length>1
            e.inputType = 'select'
            e.selections = e.AllowedValues.split(',')
            return
          else
            e.inputType = 'input'
            return
        that.manager.setSlide tpl {data:data, preview: true}
        $("#rds-pg-save").click ->
          that.modifyParams(parameters, getChange())
        $("#pg-back-to-edit").click ->
          checked = [data: id: parameters.groupModel.id]
          (that.getSlides().edit.bind that) tpl, checked

    modifyParams: (parameters, change)->
      changeMap = {}
      _.each change, (e)->
        changeMap[e.ParameterName] = e.newValue
      _.each parameters.models, (d)->
        d.unset 'newValue' #unset newValue Attribute
      afterModify = @afterModify.bind @
      @switchAction 'processing'
      parameters.groupModel.modifyParams(changeMap).then afterModify, afterModify

    afterModify: (result)->
      @manager.cancel()
      if (result?.error)
        notification 'error', "Parameter Group updated failed because of "+result?.msg
        return false
      notification 'info', "Parameter Group is updated."

    doAction: (action, checked)->
      @["do_"+action] and @["do_"+action]('do_'+action,checked)

    do_create: ->
      if not (($( '#property-dbpg-name-create' ).parsley 'validate') and ($( '#property-dbpg-desc-create' ).parsley 'validate'))
        return false
      data =
        "DBParameterGroupName": $("#property-dbpg-name-create").val()
        'DBParameterGroupFamily': $("#property-family .selection").html().trim()
        'Description': $('#property-dbpg-desc-create').val()
      @switchAction 'processing'
      afterCreated = @afterCreated.bind @
      @collection.create(data).save().then afterCreated, afterCreated

    do_delete: (invalid, checked)->
      that = @
      deleteCount += checked.length
      @switchAction 'processing'
      afterDeleted = that.afterDeleted.bind that
      _.each checked, (data)=>
        @collection.findWhere(id: data.data.id).destroy().then afterDeleted, afterDeleted

    do_edit: (invalid, checked)->
      ###
      ###


    do_reset: (invalid, checked)->
      sourceDbpg = checked[0]
      @switchAction 'processing'
      afterReset = @afterReset.bind @
      @collection.findWhere(id: sourceDbpg.data.id).resetParams().then afterReset, afterReset


    afterCreated: (result)->
      @manager.cancel()
      if result.error
        notification 'error', "Create failed because of: "+result.msg
        return false
      notification 'info', "New RDS Parameter Group is created successfully!"
      #@collection.add newDbpg

    afterReset: (result)->
      currentRegion = Design.instance().get('region')
      @manager.cancel()
      if result.error
        notification 'error', result.awsResult
        return false
      #cancelselect && fetch
      notification 'info', "RDS Parameter Group is reset successfully!"

    afterDeleted: (result)->
      deleteCount--
      if result.error
        deleteErrorCount++
      if deleteCount is 0
        if deleteErrorCount > 0
          notification 'error', deleteErrorCount+" RDS Parameter Group failed to delete, Please try again later."
        else
          notification 'info', "Delete Successfully"
        @manager.unCheckSelectAll()
        deleteErrorCount = 0
        @manager.cancel()

    switchAction: ( state ) ->
      if not state
        state = 'init'
      @M$( '.slidebox .action' ).each () ->
        if $(@).hasClass state
          $(@).show()
        else
          $(@).hide()

    renderDropdown: ->
      that = this
      option =
        manageBtnValue: lang.ide.PROP_VPC_MANAGE_RDS_PG
        filterPlaceHolder: lang.ide.PROP_VPC_FILTER_RDS_PG
      @dropdown = new combo_dropdown option
      @collection.fetch().then ->
        data = that.collection.toJSON()

      @dropdown.setSelection @resModel.attributes.pgName
      @dropdown.on 'open',   (@initDropdown.bind @) , @
      @dropdown.on 'manage', (@renderManager.bind @), @
      @dropdown.on 'filter', (@filterDropdown.bind @), @
      @dropdown.on 'change', (@setParameterGroup.bind @), @
      @dropdown
    initDropdown: ->
      if App.user.hasCredential()
        @renderDefault()
      else
        @renderNoCredential()

    renderDefault: ->
      if not fetched
        @renderLoading()
        @collection.fetch().then =>
          @renderDefault()
        fetched = true
        return false
      @openDropdown()

    renderNoCredential: ->
      @dropdown.render('nocredential').toggleControls false

    renderLoading: ->
      @dropdown.render('loading').toggleControls false

    openDropdown: (keys)->
      data = @collection.toJSON()
      selected = @resModel.attributes.pgName
      _.each data, (e)->
        if e.DBParameterGroupName is selected
          e.selected = true
      datas = keys: data
      if keys
        datas.keys = keys
      if Design.instance().modeIsApp() or Design.instance().modeIsAppEdit()
        datas.isRunTime = true
      content = template.keys datas
      @dropdown.toggleControls true
      @dropdown.setContent content

    filterDropdown: ( keyword ) ->
      hitKeys = _.filter @collection.toJSON(), ( data ) ->
        data.id.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
      if keyword
        @openDropdown hitKeys
      else
        @openDropdown()

    setParameterGroup: (value, data)->
      val = value || data.id
      @resModel.set("pgName", val)


    getModalOptions: ->
      that = @
      region = Design.instance().get('region')
      regionName = constant.REGION_SHORT_LABEL[ region ]

      title: "Manage RDS Parameter Group in #{regionName}"
      slideable: true
      context: that
      buttons: [
        {
          icon: 'new-stack'
          type: 'create'
          name: 'Create RDS PG'
        }
        {
          icon: 'edit'
          type: 'edit'
          disabled: true
          name: ' Edit '
        }
        {
          icon: 'reset'
          type: 'reset'
          disabled: true
          name: 'Reset'
        }
        {
          icon: 'del'
          type: 'delete'
          disabled: true
          name: 'Delete'
        }
        {
          icon: 'refresh'
          type: 'refresh'
          name: ''
        }
      ]
      columns: [
        {
          sortable: true
          width: "30%" # or 40%
          name: 'Name'
          rowType: "string"
        }
        {
          sortable: true
          rowType: 'string'
          width: "30%" # or 40%
          name: 'Family'
        }
        {
          sortable: false
          width: "40%" # or 40%
          name: 'Description'
        }
      ]

  DbpgRes
