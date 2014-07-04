define ['CloudResources', 'ApiRequest', 'constant', "UI.modalplus", 'toolbar_modal', "i18n!/nls/lang.js", 'component/rds/template'], (CloudResources, ApiRequest , constant, modalPlus, toolbar_modal, lang, template)->
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

    selectDbpg: ->
      @manager.$el.find('[data-action="create"]').prop 'disabled', false

    selectRegion: ->
      @manager.$el.find('[data-action="duplicate"]').prop 'disabled', false

    renderManager: ()->
      @manager = new toolbar_modal @getModalOptions()
      @manager.on 'refresh', @refresh, @
      @manager.on "slidedown", @renderSlides, @
      @manager.on 'action', @doAction, @
      @manager.on 'close', =>
        @manager.remove()
      @manager.on 'checked', @processDuplicate, @

      @manager.render()
      if not App.user.hasCredential()
        @manager?.render 'nocredential'
        return false
      @initManager()

    processDuplicate: ( event, checked ) ->
      if checked.length is 1
        @M$('[data-btn=duplicate]').prop 'disabled', false
      else
        @M$('[data-btn=duplicate]').prop 'disabled', true

    refresh: ->
      fetched = false
      @initManager()

    setContent: ->
      fetching = false
      fetched = true
      data = @collection.toJSON()
      _.each data, (e,f)->
        if e.progress is 100
          data[f].completed = true
        if e.startTime
          data[f].started = (new Date(e.startTime)).toString()
        null
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
        data =
          volumes : {}
        @manager.setSlide tpl data

      'duplicate': (tpl, checked)->
        data = {}
        data.originDbpg = checked[0]
        data.region = Design.instance().get('region')
        if not checked
          return
        @manager.setSlide tpl data

    doAction: (action, checked)->
      @["do_"+action] and @["do_"+action]('do_'+action,checked)

    do_create: ->
      volume = @volumes.findWhere('id': $('#property-volume-choose').find('.selectbox .selection .manager-content-main').data('id'))
      if not volume
        return false
      data =
        "name": $("#property-dbpg-name-create").val()
        'volumeId': volume.id
        'description': $('#property-dbpg-desc-create').val()
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

    do_duplicate: (invalid, checked)->
      sourceDbpg = checked[0]
      targetRegion = $('#property-region-choose').find('.selectbox .selection .manager-content-main').data('id')
      if (@regions.indexOf targetRegion) < 0
        return false
      @switchAction 'processing'
      newName = @manager.$el.find('#property-dbpg-name').val()
      description =  @manager.$el.find('#property-dbpg-desc').val()
      afterDuplicate = @afterDuplicate.bind @
      @collection.findWhere(id: sourceDbpg.data.id).copyTo( targetRegion, newName, description).then afterDuplicate, afterDuplicate


    afterCreated: (result)->
      @manager.cancel()
      if result.error
        notification 'error', "Create failed because of: "+result.msg
        return false
      notification 'info', "New DHCP Option is created successfully!"
  #@collection.add newDbpg

    afterDuplicate: (result)->
      currentRegion = Design.instance().get('region')
      @manager.cancel()
      if result.error
        notification 'error', "Duplicate failed because of: "+ result.msg
        return false
      #cancelselect && fetch
      if result.attributes.region is currentRegion
        @collection.add result
        notification 'info', "New RDS Parameter Group is duplicated successfully!"
      else
        @initManager()
        notification 'info', 'New RDS Parameter Group is duplicated to another region, you need to switch region to check the dbpg you just created.'

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
          name: 'Create'
        }
        {
          icon: 'duplicate'
          type: 'duplicate'
          disabled: true
          name: 'Duplicate'
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
          width: "20%" # or 40%
          name: 'Name'
        }
        {
          sortable: true
          rowType: 'number'
          width: "10%" # or 40%
          name: 'Capicity'
        }
        {
          sortable: true
          rowType: 'datetime'
          width: "40%" # or 40%
          name: 'status'
        }
        {
          sortable: false
          width: "30%" # or 40%
          name: 'Description'
        }
      ]

  DbpgRes
