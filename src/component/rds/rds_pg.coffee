define ['CloudResources', 'ApiRequest', 'constant', "UI.modalplus", 'combo_dropdown', 'toolbar_modal', "i18n!/nls/lang.js", 'component/rds/template'], (CloudResources, ApiRequest , constant, modalPlus, combo_dropdown, toolbar_modal, lang, template)->
  fetched = false
  deleteCount = 0
  deleteErrorCount = 0
  fetching = false
  regionsMark = {}
  DbpgRes = Backbone.View.extend
    constructor: ()->
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
      @manager.on 'checked', @processReset, @

      @manager.render()
      if not App.user.hasCredential()
        @manager?.render 'nocredential'
        return false
      @initManager()

    processReset: ( event, checked ) ->
      if checked.length is 1 and not @collection.findWhere( id: checked[0].data.id ).isDefault()
        @M$('[data-btn=reset],[data-btn=edit]').prop 'disabled', false
      else
        @M$('[data-btn=reset],[data-btn=edit]').prop 'disabled', true
      that = @
      allNotDefault = _.every checked, (e)->
        val =  not that.collection.findWhere(id: e.data.id).isDefault()
        console.log(val)
        return val
      console.log(allNotDefault,"AllNowDefault")
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

    initManager: ()->
      setContent = @setContent.bind @
      currentRegion = Design.instance().get('region')
      if (not fetched and not fetching) or (not regionsMark[currentRegion])
        fetching = true
        regionsMark[currentRegion] = true
        @collection.fetchForce().then setContent, setContent
      else if not fetching
        @setContent()

    renderSlides: (which, checked)->
      tpl = template['slide_'+ which]
      slides = @getSlides()
      slides[which]?.call @, tpl, checked
      if(which == "create")
        $(".slidebox").css("height": "100%")
      else
        $(".slidebox").removeAttr("style")



    getSlides: ->
      'delete': (tpl, checked)->
        checkedAmount = checked.length
        if not checkedAmount
          return
        data = {}
        if checkedAmount is 1
          data.selectedName = checked[0].data.name
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

      'edit': (tpl, checked)->
        if not checked then return false
        that = @
        target = @collection.findWhere(id: checked[0].data.id)
        parameters = target.getParameters()
        that.manager.setSlide template.loading()
        parameters.fetch().then ->
          data = data: parameters.toJSON()
          _.each data.data, (e)->
            if not e.AllowedValues then console.log(e)
            if e.AllowedValues?.split(',').length>1
              e.inputType = 'select'
              e.selections = e.AllowedValues.split(',')
              if e.ParameterValue
                console.log(e.ParameterValue,'---')
                console.log(e)
              return
            else
              e.inputType = 'input'
              return
          that.manager.setSlide tpl data
          $(".slidebox .content").css(
            "width": "100%"
            "margin-top": "0px"
          )

      'reset': (tpl, checked)->
        data = name: checked[0].data.id
        if not checked
          return
        @manager.setSlide tpl data

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
        notification 'error', "Reset failed because of: "+ result.msg
        return false
      #cancelselect && fetch
      @collection.add result
      notification 'info', "RDS Parameter Group is resetd successfully!"

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
