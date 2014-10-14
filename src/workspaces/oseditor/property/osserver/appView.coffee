define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    'underscore'
    'OsKp'
    '../ossglist/view'
], ( constant, OsPropertyView, template, CloudResources, _, OsKp, SgListView ) ->

  OsPropertyView.extend {

    events:

        'click .os-server-image-info': 'openImageInfoPanel'

    initialize: ->

        @sgListView = new SgListView {
            panel: @panel,
            targetModel: @model.embedPort()
        }

    render: ->

        appData = @getRenderData()

        # if appData and appData.launch_at
        #     appData.launch_at = new Date(appData.launch_at)
        addrData = {}

        # get address info
        addressData = appData?.address?.addresses
        if addressData
            _.each addressData, (addrAry) ->
                _.each addrAry, (addrObj) ->
                    if addrObj.type is 'fixed'
                        addrData.fixedIp = addrObj.addr
                        addrData.macAddress = addrObj.mac_addr
                    if addrObj.type is 'floating'
                        addrData.floatingIp = addrObj.addr
                    null
                null

        @$el.html template.appTemplate _.extend(appData, addrData)
        # append sglist
        @$el.append @sgListView.render().el
        @

    openImageInfoPanel: ->

        serverData = @getRenderData()
        @showFloatPanel(template.imageTemplate(serverData.system_metadata))

    }, {
        handleTypes: [ constant.RESTYPE.OSSERVER ]
        handleModes: [ 'app' ]
    }
