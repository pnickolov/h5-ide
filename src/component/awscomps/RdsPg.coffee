define ['CloudResources', 'ApiRequest', 'constant', "UI.modalplus", 'combo_dropdown', 'toolbar_modal', "i18n!/nls/lang.js", 'component/awscomps/RdsPgTpl'], (CloudResources, ApiRequest , constant, modalPlus, combo_dropdown, toolbar_modal, lang, template)->
  fetched = false
  deleteCount = 0
  deleteErrorCount = 0
  fetching = false
  regionsMark = {}
  DbpgRes = Backbone.View.extend
    constructor: (model)->
      if model then @resModel = model
      @collection = CloudResources Design.instance().credentialId(), constant.RESTYPE.DBPG, Design.instance().region()
      @listenTo @collection, 'update', (@onUpdate.bind @)
      @listenTo @collection, 'change', (@onUpdate.bind @)
      @listenTo @collection, 'remove', (@onRemove.bind @)
      @listenTo @collection, 'add',    (@onAdd.bind @)
      @

    onUpdate: ->
      @initManager()
      @trigger 'datachange', @
    onAdd: ->
      @initDropdown()
    onRemove: ->
      @initDropdown()
      if @resModel and  not (@collection.get @resModel.get('pgName'))
        @resModel.setDefaultParameterGroup( @resModel.get 'engineVersion' )
      @dropdown?.setSelection @resModel.get('pgName')

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
      @manager.on 'slideup', @slideDown, @
      @manager.on 'action', @doAction, @
      @manager.on 'close', =>
        @manager.remove()
        @collection.remove()
      @manager.on 'checked', @processReset, @

      @manager.render()
      if Design.instance().credential()?.isDemo()
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

      _.each data, (e)->
        if e.DBParameterGroupName.indexOf("default.") is 0
          e.isDefault = true
          e

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

    slideDown: (param, checked)->
      if param is "edit" and checked.length is 1
        target = @collection.findWhere(id: checked[0].data.id)
        parameters = target.getParameters()
        parameters.fetch().then (result)->
          _.each result.models, (e)->
            if e.has("newValue") then e.unset("newValue")


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
        @families = CloudResources Design.instance().credentialId(), constant.RESTYPE.DBENGINE, Design.instance().get("region")
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
      isNumberString = (e)->
        !isNaN(parseFloat(e)) && isFinite(e)
      isMixedValue = (e)->
        isMixed = false
        tempArray = e.split(",")
        _.each tempArray, (value)->
          range = value.split('-')
          if range.length == 2 and isNumberString(range[0]) and isNumberString(range[1])
            isMixed = true
            null
        isMixed
      _.each data, (e)->
        if e.AllowedValues?.split(',').length > 1 and not isMixedValue(e.AllowedValues)
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
      console.log "Rendering...."
      that.manager.setSlide tpl {data:data, height: $('.table-head-fix.will-be-covered>div').height() - 76}
      $(".slidebox").css('max-height', "none")
      @manager.on "slideup", ->
        $('.slidebox').removeAttr("style")
      $(window).on 'resize', ->
        $("#parameter-table").height($('.table-head-fix.will-be-covered>div').height() - 67)
        .find(".scrollbar-veritical-thumb").removeAttr("style")

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
        if that.filterDelay
          window.clearTimeout(that.filterDelay)
        that.filterDelay = window.setTimeout ->
          (that.getSlides().edit.bind that) template.slide_edit, checked, {filter: val,sort: sortType}
        , 200
        null
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
          if e.isValidValue(this.value) or this.value is "" or (e.isFunctionValue(this.value) and not e.isNumber(this.value))
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
        $("#parameter-table").height($('.table-head-fix.will-be-covered>div').height() - 67)
        .find(".scrollbar-veritical-thumb").removeAttr("style")
        $("#rds-pg-save").click ->
          that.modifyParams(parameters, getChange())
        $("#pg-back-to-edit").click ->
          checked = [data: id: parameters.groupModel.id]
          (that.getSlides().edit.bind that) tpl, checked

    modifyParams: (parameters, change)->
      changeMap = {}
      _.each change, (e)->
        changeMap[e.ParameterName] = e.newValue
        null
      _.each parameters.models, (d)->
        d.unset 'newValue' #unset newValue Attribute
      afterModify = @afterModify.bind @
      @switchAction 'processing'
      parameters.groupModel.modifyParams(changeMap).then afterModify, afterModify

    afterModify: (result)->
      if (result?.error)
        notification 'error', sprintf lang.NOTIFY.PARAMETER_GROUP_UPDATED_FAILED, ( result?.awsResult || result?.awsErrorCode || result?.msg )
        @switchAction()
        return false
      notification 'info', lang.NOTIFY.PARAMETER_GROUP_IS_UPDATED
      @manager.cancel()

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
        notification 'error', sprintf lang.NOTIFY.CREATE_FAILED_BECAUSE_OF_XXX, result.msg
        return false
      notification 'info', lang.NOTIFY.NEW_RDS_PARAMETER_GROUP_IS_CREATED_SUCCESSFULLY
      #@collection.add newDbpg

    afterReset: (result)->
      currentRegion = Design.instance().get('region')
      @manager.cancel()
      if result.error
        notification 'error', result.awsResult
        return false
      #cancelselect && fetch
      notification 'info', lang.NOTIFY.RDS_PARAMETER_GROUP_IS_RESET_SUCCESSFULLY

    afterDeleted: (result)->
      deleteCount--
      if result.error
        deleteErrorCount++
      if deleteCount is 0
        if deleteErrorCount > 0
          @manager.error (result.awsResult || sprintf lang.IDE.RDS_DELETE_DB_PG_FAILED, deleteErrorCount )
          @switchAction()
          deleteErrorCount = 0
          null
        else
          notification 'info', lang.NOTIFY.DELETE_SUCCESSFULLY
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
        manageBtnValue: lang.PROP.VPC_MANAGE_RDS_PG
        filterPlaceHolder: lang.PROP.VPC_FILTER_RDS_PG
      @dropdown = new combo_dropdown option
      if @resModel and  not @resModel.attributes.pgName
        that.dropdown.setSelection "Please Select Parameter Group"
      else
        @dropdown.setSelection @resModel.attributes.pgName
      @dropdown.on 'open',   (@initDropdown.bind @) , @
      @dropdown.on 'manage', (@renderManager.bind @), @
      @dropdown.on 'filter', (@filterDropdown.bind @), @
      @dropdown.on 'change', (@setParameterGroup.bind @), @
      @dropdown
    initDropdown: ->
      if Design.instance().credential() and not Design.instance().credential().isDemo()
        @renderDefault()
      else
        @renderNoCredential()

    renderDefault: ->
      if not @dropdown then return false
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
          null
      datas = keys: data
      if keys
        datas.keys = keys
      if Design.instance().modeIsApp() or Design.instance().modeIsAppEdit()
        datas.isRunTime = true

      modelData  = @resModel.attributes
      regionName = Design.instance().region()
      engineCol  = CloudResources(Design.instance().credentialId(), constant.RESTYPE.DBENGINE, regionName)
      if engineCol
        defaultInfo  = engineCol.getDefaultByNameVersion regionName, modelData.engine, modelData.engineVersion
        targetFamily = defaultInfo.family


      if targetFamily
        datas.keys = _.filter datas.keys, (e)->
          e.DBParameterGroupFamily == targetFamily

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

      title: sprintf(lang.IDE.COMPONENT_RDS_PG_MANAGER_TITLE, regionName)#"Manage DB Parameter Group in #{regionName}"
      slideable: true
      context: that
      buttons: [
        {
          icon: 'new-stack'
          type: 'create'
          name: lang.PROP.LBL_CREATE_PARAMETER_GROUP
        }
        {
          icon: 'edit'
          type: 'edit'
          disabled: true
          name: lang.PROP.LBL_EDIT
        }
        {
          icon: 'reset'
          type: 'reset'
          disabled: true
          name: lang.PROP.LBL_RESET
        }
        {
          icon: 'del'
          type: 'delete'
          disabled: true
          name: lang.PROP.LBL_DELETE
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
          rowType: "string"
          name: lang.PROP.NAME
        }
        {
          sortable: true
          rowType: 'string'
          width: "30%" # or 40%
          name: lang.PROP.DBPG_SET_FAMILY
        }
        {
          sortable: false
          width: "40%" # or 40%
          name: lang.PROP.LBL_DESC
        }
      ]

  DbpgRes
