define ['CloudResources', 'ApiRequest', 'constant', 'combo_dropdown', "UI.modalplus", 'toolbar_modal', "i18n!/nls/lang.js", 'component/oscomps/SnapshotTpl', 'UI.selection'], (CloudResources, ApiRequest , constant, combo_dropdown, modalPlus, toolbar_modal, lang, template, bindSelection)->
    fetched = false
    deleteCount = 0
    deleteErrorCount = 0
    fetching = false
    regionsMark = {}
    Backbone.View.extend
        constructor: ()->
            @collection = CloudResources constant.RESTYPE.OSSNAP, Design.instance().region()
            @listenTo @collection, 'update', (@onChange.bind @)
            @listenTo @collection, 'change', (@onChange.bind @)
            @

        onChange: ->
            @initManager()
            @trigger 'datachange', @

        remove: ()->
            @.isRemoved = true
            Backbone.View::remove.call @

        render: ()->
            @renderManager()

        bindVolumeSelection: ()->
            that = @
            @volumes = CloudResources constant.RESTYPE.OSVOL, Design.instance().region()
            @manager.$el.on 'select_change', "#snapshot-volume-choose", ->
              that.selectSnapshot()
            @manager.$el.on 'select_initialize', "#snapshot-volume-choose",->
              that.selectize = @selectize
              @selectize.setLoading true
              that.manager.$el.find("#snapshot-volume-choose").on 'select_dropdown_open', ->
                that.selectize.load (cb)->
                  that.volumes.fetch().then ->
                    volData = _.map that.volumes.toJSON(), (e)->
                      {text: e.name, value: e.id}
                    that.selectize.setLoading false
                    cb(volData)
#            @dropdown.on 'open', @openDropdown, @
#            @dropdown.on 'change', @selectSnapshot, @
#            @dropdown

        renderRegionDropdown: ()->
            option =
                filterPlaceHolder: lang.PROP.SNAPSHOT_FILTER_REGION
            @regionsDropdown = new combo_dropdown(option)
            @regions = _.keys constant.REGION_LABEL
            selection = lang.PROP.VOLUME_SNAPSHOT_SELECT_REGION
            @regionsDropdown.setSelection selection
            @regionsDropdown.on 'open', @openRegionDropdown, @
            @regionsDropdown.on 'filter', @filterRegionDropdown, @
            @regionsDropdown.on 'change', @selectRegion, @
            @regionsDropdown

        openRegionDropdown: (keySet)->
            currentRegion = Design.instance().get 'region'
            data = _.map @regions, (region)->
                {name: constant.REGION_LABEL[region]+" - "+constant.REGION_SHORT_LABEL[ region ], selected: region == currentRegion, region: region}
            dataSet =
                isRuntime: false
                data: data
            if keySet
                dataSet.data = keySet
                dataSet.hideDefaultNoKey = true
            content = template.keys dataSet
            @regionsDropdown.toggleControls false, 'manage'
            @regionsDropdown.toggleControls true, 'filter'
            @regionsDropdown.setContent content

        openDropdown: (keySet)->
            @volumes.fetch().then =>
                data = @volumes.toJSON()
                dataSet =
                    isRuntime: false
                    data: data
                if keySet
                    dataSet.data = keySet
                    dataSet.hideDefaultNoKey = true
                content = template.keys dataSet
                @dropdown.toggleControls false, 'manage'
                @dropdown.toggleControls true, 'filter'
                @dropdown.setContent content



        filterRegionDropdown: (keyword)->
            hitKeys = _.filter @regions, ( data ) ->
                data.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
            if keyword
                @openRegionDropdown hitKeys
            else
                @openRegionDropdown()


        selectSnapshot: (e)->
            @manager.$el.find('[data-action="create"]').prop 'disabled', false

        selectRegion: (e)->
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
            data = _.map data, (e,f)->
                if e.status is "available"
                    e.completed = true
                if e.created_at
                    e.started = (new Date(e.created_at)).toString()
                e
            dataSet =
                items: data
            content = template.content dataSet
            @manager?.setContent content

        initManager: ()->
            setContent = @setContent.bind @
            currentRegion = Design.instance()?.get('region')
            if currentRegion and ((not fetched and not fetching) or (not regionsMark[currentRegion]))
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
                bindSelection @manager.$el, @selectionTemplate.call(@)
                @bindVolumeSelection()
                @manager.setSlide tpl data

#            'duplicate': (tpl, checked)->
#                data = {}
#                data.originSnapshot = checked[0]
#                data.region = Design.instance().get('region')
#                if not checked
#                    return
#                @manager.setSlide tpl data
#                @regionsDropdown = @renderRegionDropdown()
#                @regionsDropdown.on 'change', =>
#                    @manager.$el.find('[data-action="duplicate"]').prop 'disabled', false
#
#                @manager.$el.find('#property-region-choose').html(@regionsDropdown.$el)

        doAction: (action, checked)->
            @["do_"+action] and @["do_"+action]('do_'+action,checked)

        do_create: (validate, checked)->
            volumeId = @selectize.getValue()
            if not volumeId then return false
            volume = @volumes.findWhere('id': @selectize.getValue())
            if not volume
                return false
            data =
                "name": $("#property-snapshot-name-create").val()
                'volume_id': volume.get('id')
                'description': $('#property-snapshot-desc-create').val()
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
            sourceSnapshot = checked[0]
            targetRegion = $('#property-region-choose').find('.selectbox .selection .manager-content-main').data('id')
            if (@regions.indexOf targetRegion) < 0
                return false
            @switchAction 'processing'
            newName = @manager.$el.find('#property-snapshot-name').val()
            description =  @manager.$el.find('#property-snapshot-desc').val()
            afterDuplicate = @afterDuplicate.bind @
            @collection.findWhere(id: sourceSnapshot.data.id).copyTo( targetRegion, newName, description).then afterDuplicate, afterDuplicate


        afterCreated: (result,newSnapshot)->
            @manager.cancel()
            if result.error
                notification 'error', sprintf lang.NOTIFY.CREATE_FAILED_BECAUSE_OF_XXX, result.msg
                return false
            notification 'info', lang.NOTIFY.NEW_SNAPSHOT_IS_CREATED_SUCCESSFULLY
            #@collection.add newSnapshot

        afterDuplicate: (result)->
            currentRegion = Design.instance().get('region')
            @manager.cancel()
            if result.error
                notification 'error', sprintf, lang.NOTIFY.DUPLICATE_FAILED_BECAUSE_OF_XXX, result.msg
                return false
            #cancelselect && fetch
            if result.attributes.region is currentRegion
                @collection.add result
                notification 'info', lang.NOTIFY.INFO_DUPLICATE_SNAPSHOT_SUCCESS
            else
                @initManager()
                notification 'info', lang.NOTIFY.INFO_ANOTHER_REGION_DUPLICATE_SNAPSHOT_SUCCESS

        afterDeleted: (result)->
            deleteCount--
            if result.error
                deleteErrorCount++
            if deleteCount is 0
                if deleteErrorCount > 0
                    notification 'error', sprintf lang.NOTIFY.XXX_SNAPSHOT_FAILED_TO_DELETE, deleteErrorCount
                else
                    notification 'info', lang.NOTIFY.INFO_DELETE_SNAPSHOT_SUCCESSFULLY
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

        selectionTemplate: ->
          that = @
          {
            option: (result)->
              volume = that.volumes.get(result.value)
              template.option volume.toJSON()
            item: template.item
          }

        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ] || region

            title: "Manage Snapshots in #{regionName}"
            slideable: true
            context: that
            buttons: [
                {
                    icon: 'new-stack'
                    type: 'create'
                    name: 'Create Snapshot'
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

