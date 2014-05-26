define ["CloudResources", 'constant','combo_dropdown', 'UI.modalplus', 'toolbar_modal'], ( CloudResources, constant, comboDropdown, modalPlus, toolbarModal )->
    dhcpManager = Backbone.View.extend
        constructor:(region_name)->
            @collection = CloudResources constant.RESTYPE.DHCP, region_name
            @collection.fetch ()=>
                @renderDhcpList()
            @listenTo dhcpColl, 'change', @renderDhcpList
            option =
                manageBtnValue: lang.ide.PROP_VPC_MANAGE_DHCP
                filterPlaceHolder: lang.ide.PROP_VPC_FILTER_DHCP
            @dropdown = new comboDropdown option
            @dropdown.on 'open', @show , @
            @dropdown.on 'manage', @manageDHCP, @
            @dropdown.on 'change', @setDHCP, @
            @dropdown.on 'filter', @filter, @
            @
        remove: ()->
            @.isRemoved = true
            Backbone.View::remove.call @
        renderDhcpList: ->
            console.log @collection.toJSON()
        show: ->
            if App.user.hasCredential()
                if not @fetched
                    @collection.fetch()
            else
                @renderNoCredential()
        renderNoCredential: ->
            @dropdown.render('no-credential').toggleControls false
        renderLoading: ->
            @dropdown.render('loading').toggleControls false
        
    dhcpManager