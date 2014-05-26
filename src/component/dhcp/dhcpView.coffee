define ["CloudResources", 'constant','combo_dropdown', 'UI.modalplus', 'toolbar_modal'], ( CloudResources, constant, comboDropdown, modalPlus, toolbarModal )->
    DhcpManager = Backbone.View.extend
        initialize:(region_name)->
            dhcpColl = CloudResources constant.RESTYPE.DHCP, region_name
            dhcpColl.fetch ()=>
                @renderDhcpList()
            @listenTo dhcpColl, 'change', @renderDhcpList
        remove: ()->
            @.isRemoved = true
            Backbone.View::remove.call @
        renderDhcpList: ->
            dhcpColl = CloudResources 'us-east-1', constant.DHCP
            console.log dhcpColl