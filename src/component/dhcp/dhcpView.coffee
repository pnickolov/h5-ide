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
            @dropdown.on 'manage', @manageDHCP, @
            @dropdown.on 'change', @setDHCP, @
            @dropdown.on 'filter', @filter, @
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
                targetDhcp = e
            else if e is @default
                targetDhcp = e
            else
                targetDhcp = @collection.findWhere
                    id: e
            console.log targetDhcp, e
            @trigger 'change', targetDhcp
    dhcpView