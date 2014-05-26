define ["CloudResources", 'constant'], ( CloudResources, constant )->
    DhcpManager = Backbone.View.extend
        initialize:->
            dhcpColl = CloudResources 'us-east-1', constant.DHCP
            dhcpColl.fetch ()=>
                @renderDhcpList()
            @listenTo dhcpColl, 'change', @renderDhcpList
        remove: ()->
            @.isRemoved = true
            Backbone.View::remove.call @
        renderDhcpList: ->
            dhcpColl = CloudResources 'us-east-1', constant.DHCP
            console.log dhcpColl
