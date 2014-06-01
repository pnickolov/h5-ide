define ['CloudResources', 'ApiRequest', 'constant', 'combo_dropdown', "UI.modalplus", 'toolbar_modal', "i18n!nls/lang.js", './component/snapshot/snapshot_template.js'], (CloudResources, ApiRequest , constant, combo_dropdown, modalPlus, toolbar_modal, lang, template)->
    fetched = false
    snapshotRes = Backbone.View.extend
        constructor: ()->
            @collection = CloudResources constant.RESTYPE.SNAP, Design.instance().region()
            @collection.on 'change', @onChange
            @collection.on 'update', @onChange
            @
        onChange: ->
            @trigger 'datachange', @

        remove: ()->
            @.isRemoved = ture
            Backbone.View::remove.call @

        render: ()->
            if App.user.hasCredential()
                @renderManager()
            else
                @renderNoCredential()

        renderDropdown: ()->
            option =
                manageBtnValue: lang.ide.PROP_VPC_MANAGE_SNAPSHOT
                filterPlaceHolder: lang.ide.PROP_SNAPSHOT_FILTER_SNAPSHOT
            @dropdown = new combo_dropdown(option)
            @volumes = CloudResources constant.RESTYPE.VOL, Design.instance().region()
            selection = lang.ide.PROP_VOLUME_SNAPSHOT_SELECT
            @dropdown.setSelection selection

            @dropdown.on 'open', @openDropdown, @
            @dropdown.on 'filter', @filterDropdown, @
            @dropdown.on 'change', @selectSnapshot, @
            @dropdown

        renderRegionDropdown: ()->
            option =
                filterPlaceHolder: lang.ide.PROP_SNAPSHOT_FILTER_REGION
            @regionsDropdown = new combo_dropdown(option)
            @regions = _.keys constant.REGION_LABEL
            selection = lang.ide.PROP_VOLUME_SNAPSHOT_SELECT_REGION
            @regionsDropdown.setSelection selection
            @regionsDropdown.on 'open', @openRegionDropdown, @
            @regionsDropdown.on 'filter', @filterRegionDropdown, @
            @regionsDropdown.on 'change', @selectRegion, @
            @regionsDropdown

        openRegionDropdown: (keySet)->
            data = @regions
            @regionsDropdown.setContent content
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

        filterDropdown: (keyword)->
            hitKeys = _.filter @volumes.toJSON(), ( data ) ->
                data.id.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
            if keyword
                @openDropdown hitKeys
            else
                @openDropdown()


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

        renderNoCredential: ->
            new modalPlus(
                title: lang.ide.SETTINGS_CRED_DEMO_SETUP
                template: lang.ide.SETTINGS_CRED_DEMO_TIT
            )
        renderManager: ()->
            @manager = new toolbar_modal @getModalOptions()
            @manager.on 'refresh', @refresh, @
            @manager.on "slidedown", @renderSlides, @
            @manager.on 'action', @doAction, @
            @manager.on 'close', =>
                @manager.remove()
            @manager.render()
            @initManager()

        refresh: ->
            fetched = false
            @initManager()

        setContent: ->
            data = @collection.toJSON()
            _.each data, (e,f)->
                if e.progress is 100
                    data[f].completed = true
                    null
            dataSet =
                items: data
            content = template.content dataSet
            @manager?.setContent content

        initManager: ()->
            setContent = @setContent.bind @
            if not fetched
                fetched = true
                @collection.fetchForce().then setContent, setContent
            else
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
                @dropdown = @dropdown or @renderDropdown()

                @manager.$el.find('#property-volume-choose').html(@dropdown.$el)
            'duplicate': (tpl, checked)->
                data = {}
                data.originSnapshot = checked[0]
                if not checked
                    return
                @manager.setSlide tpl data
                @regionsDropdown = @regionsDropdown or @renderRegionDropdown()
                @regionsDropdown.on 'change', =>
                    @manager.$el.find('[data-action="duplicate"]').prop 'disabled', false

                @manager.$el.find('#property-region-choose').html(@regionsDropdown.$el)


        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

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
                    width: "20%" # or 40%
                    name: 'Capicity'
                }
                {
                    sortable: true
                    width: "30%" # or 40%
                    name: 'status'
                }
                {
                    sortable: false
                    width: "30%" # or 40%
                    name: 'Description'
                }
            ]

    snapshotRes