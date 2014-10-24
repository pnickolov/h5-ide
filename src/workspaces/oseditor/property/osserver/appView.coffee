define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    'underscore'
    'OsKp'
    '../ossglist/view'
    'ApiRequestOs'

], ( constant, OsPropertyView, template, CloudResources, _, OsKp, SgListView, ApiRequest ) ->

  OsPropertyView.extend {

    events:

        'click .os-server-image-info'        : 'openImageInfoPanel'
        'click .property-btn-get-system-log' : 'openSysLogModal'

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

        @flavorList = App.model.getOpenstackFlavors( Design.instance().get("provider"), Design.instance().region() )
        flavorObj = @flavorList.get(appData.flavor_id)
        appData.vcpus = flavorObj.get("vcpus")
        appData.ram = Math.round(flavorObj.get("ram") / 1024)
        @$el.html template.appTemplate _.extend(appData, addrData)
        # append sglist
        @$el.append @sgListView.render().el
        @

    openSysLogModal : () ->
        serverId = @model.get('appId')

        that = this
        region = Design.instance().region()

        ApiRequest("os_server_GetConsoleOutput", {
            region : region
            server_id    : serverId
        }).then (result) ->
            console.log(result)
            that.refreshSysLog(result)

        modal MC.template.modalInstanceSysLog {
            instance_id: serverId,
            log_content: ''
        }, true

        # that.off('EC2_INS_GET_CONSOLE_OUTPUT_RETURN').on 'EC2_INS_GET_CONSOLE_OUTPUT_RETURN', (result) ->

        #     if !result.is_error
        #         console.log(result.resolved_data)
        #     that.refreshSysLog(result.resolved_data)

        false

    refreshSysLog : (result) ->
        $('#modal-instance-sys-log .instance-sys-log-loading').hide()

        if result and result.output

            logContent = result.output
            $contentElem = $('#modal-instance-sys-log .instance-sys-log-content')

            $contentElem.html MC.template.convertBreaklines({content:logContent})
            $contentElem.show()

        else

            $('#modal-instance-sys-log .instance-sys-log-info').show()

        modal.position()

    openImageInfoPanel: ->

        serverData = @getRenderData()
        @showFloatPanel(template.imageTemplate(serverData.system_metadata))

    }, {
        handleTypes: [ constant.RESTYPE.OSSERVER ]
        handleModes: [ 'app' ]
    }
