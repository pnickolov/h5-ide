define ["CloudResources", 'constant','combo_dropdown', 'UI.modalplus', 'toolbar_modal', 'i18n!nls/lang.js', './dhcp_template.js'], ( CloudResources, constant, comboDropdown, modalPlus, toolbarModal, lang, template )->
    dhcpView = Backbone.View.extend
        constructor:->
            @collection = CloudResources constant.RESTYPE.DHCP, Design.instance().region()
            @listenTo @collection, 'change', @render
            @listenTo @collection, 'update', @render
            option =
                manageBtnValue: lang.ide.PROP_VPC_MANAGE_DHCP
                filterPlaceHolder: lang.ide.PROP_VPC_FILTER_DHCP
            @dropdown = new comboDropdown option
            selection = template.selection
                isDefault: false
                isAuto: true
            @dropdown.setSelection selection
            @dropdown.on 'open', @show , @
            @dropdown.on 'manage', @manageDhcp, @
            @dropdown.on 'change', @setDHCP, @
            @dropdown.on 'filter', @filter, @
            @manager = new toolbarModal @getModalOptions()
            @
        remove: ()->
            @.isRemoved = true
            Backbone.View::remove.call @
        render: ->
            if not @collection.fetched
                @collection.fetched = true
                @renderLoading()
                @collection.fetch().then(@render)
                console.log "Fetching....."
                return false
            console.log @collection.toJSON()
            @renderDropdown()
        show: ->
            if App.user.hasCredential()
                @render()
            else
                @renderNoCredential()
        renderNoCredential: ->
            @dropdown.render('nocredential').toggleControls false
        renderLoading: ->
            @dropdown.render('loading').toggleControls false
        renderDropdown: ->
            data = @collection.toJSON()
            selection = template.selection
                isDefault: false
                isAuto: true
            content = template.keys
                isRuntime: false
                keys: data
            @dropdown.toggleControls true
            @dropdown.setSelection selection
            @dropdown.setContent content
        setDHCP: (e)->
            if e is '@auto'
                targetDhcp = id: 'auto'
            else if e is '@default'
                targetDhcp = id: "default"
            else
                targetModel = @collection.findWhere
                    id: e
                targetDhcp = targetModel.toJSON()
            @trigger 'change', targetDhcp
        setSelection: (e)->
            selection = template.selection e
            @dropdown.setSelection selection
        manageDhcp: ->
            console.log @manager
            @manager.render()
            @renderManager()
            @.trigger 'manage'
        renderManager: ->
            if not @collection.fetched
                @collection.fetch().then(@renderManager)
                return false
            console.log @collection.toJSON(),"content Data"
            content = template.content items:@collection.toJSON()
            @manager.setContent content
        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

            title: "Manage DHCP Options in #{regionName}"
            slideable: true
            context: that
            buttons: [
                {
                    icon: 'new-stack'
                    type: 'create'
                    name: 'Create DHCP Options Set'
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
                    width: "100px" # or 40%
                    name: 'Name'
                }
                {
                    sortable: false
                    width: "100px" # or 40%
                    name: 'Domain-name'
                }
            ]

    dhcpView