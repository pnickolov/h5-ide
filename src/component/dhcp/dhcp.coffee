define ["CloudResources", 'constant','combo_dropdown', 'UI.modalplus', 'toolbar_modal', 'i18n!nls/lang.js', './component/dhcp/dhcp_template.js'], ( CloudResources, constant, comboDropdown, modalPlus, toolbarModal, lang, template )->
    fetched = false
    fetching  = false
    updateAmazonCB = () ->
        rowLength = $( "#property-domain-server" ).children().length
        if rowLength > 3
            $( '#property-amazon-dns' ).attr( "disabled", true )
        else
            $( '#property-amazon-dns' ).removeAttr( "disabled" )
    mapFilterInput = ( selector ) ->
        $inputs = $( selector )
        result  = []

        for ipt in $inputs
            if ipt.value
                result.push ipt.value

        result
    deleteCount = 0
    deleteErrorCount = 0
    dhcpView = Backbone.View.extend
        constructor:(options)->
            @resModel = options?.resModel
            @collection = CloudResources constant.RESTYPE.DHCP, Design.instance().region()
            @listenTo @collection, 'change', @render
            @listenTo @collection, 'update', @render
            @listenTo @collection, 'change', -> @renderManager()
            @listenTo @collection, 'update', -> @renderManager()
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
            @
        remove: ()->
            @.isRemoved = true
            Backbone.View::remove.call @
        render: ()->
            if not fetched
                @renderLoading()
                @collection.fetch().then =>
                    @render()
                fetched = true
                return false
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

        renderDropdown: (keys)->
            selected = @resModel?.toJSON().dhcp.appId
            data = @collection.toJSON()
            datas =
                isRuntime: false
                keys: data
            if selected
                _.each data, (key)->
                    if key.id is selected
                        key.selected = true
                    return
            else
                datas.auto = true
            if selected is ""
                datas.auto = true
            else if selected and selected is 'default'
                datas.default = true
            if keys
                datas.keys = keys
                datas.hideDefaultNoKey = true
            if Design.instance().modeIsApp() or Design.instance().modeIsAppEdit()
                datas.isRunTime = true
            content = template.keys datas
            @dropdown.toggleControls true
            @dropdown.setContent content

        filter: ( keyword ) ->
            hitKeys = _.filter @collection.toJSON(), ( data ) ->
                data.id.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
            if keyword
                @renderDropdown hitKeys
            else
                @renderDropdown()

        setDHCP: (e)->
            if e is '@auto'
                targetDhcp = id: ''
            else if e is '@default'
                targetDhcp = id: "default"
            else
                targetModel = @collection.findWhere
                    id: e
                targetDhcp = targetModel.toJSON()
            @resModel.toJSON().dhcp.dhcpOptionsId = targetDhcp.id
            @trigger 'change', targetDhcp
        setSelection: (e)->
            selection = template.selection e
            @dropdown.setSelection selection
        manageDhcp: ->
            @manager = new toolbarModal @getModalOptions()
            @manager.on 'refresh', @refreshManager, @
            @manager.on 'slidedown', @renderSlides, @
            @manager.on 'action', @doAction, @
            @manager.on 'detail', @detail, @
            @manager.on 'close', =>
                @manager.remove()
            @manager.render()
            @renderManager()
            @.trigger 'manage'
        refreshManager: ->
            fetched = false
            @renderManager()
        renderManager: ->
            if not App.user.hasCredential()
                @manager?.render 'nocredential'
                return false
            initManager = @initManager.bind @
            if not fetched and not fetching
                fetching = true
                @collection.fetchForce().then initManager, initManager
            #content = template.content items:@collection.toJSON()
            else if not fetching
                initManager()
        initManager: ->
            fetching = false
            fetched = true
            content = template.content items:@collection.toJSON()
            @manager?.setContent content

        renderSlides: (which, checked)->
            tpl = template['slide_'+ which]
            slides = @getSlides()
            slides[which]?.call @, tpl, checked

        detail: (event, data, $tr) ->
            that = this
            dhcpId = data.id
            dhcpData = @collection.get(dhcpId).toJSON()
            detailTpl = template['detail_info']
            @manager.setDetail($tr, detailTpl(dhcpData))

        getSlides: ->
            "delete": (tpl, checked)->
                checkedAmount = checked.length
                if not checkedAmount
                    return
                data = {}

                if checkedAmount is 1
                    data.selectedId = checked[0].data.id
                else
                    data.selectedCount = checkedAmount
                @manager.setSlide tpl data

            'create': (tpl)->
                data =
                    dhcp: {}

                selectedType = 0
                data.dhcp.netbiosTypes = [
                    { id : "default" , value : lang.ide.PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED, selected : selectedType == 0 }
                , { id : 1 , value : 1, selected : selectedType == 1 }
                , { id : 2 , value : 2, selected : selectedType == 2 }
                , { id : 4 , value : 4, selected : selectedType == 4 }
                , { id : 8 , value : 8, selected : selectedType == 8 }
                ]
                @manager.setSlide tpl data
                @manager.$el.find("#property-amazon-dns").change (e)=> @onChangeAmazonDns(e)
                @manager.$el.find('.multi-input').on 'ADD_ROW',  (e)=> @processParsley(e)
                @manager.$el.find(".control-group .input").change (e)=> @onChangeDhcpOptions(e)
                @manager.$el.find('.formart_toolbar_modal').on 'OPTION_CHANGE REMOVE_ROW', (e)=>@onChangeDhcpOptions(e)
                @manager.$el.find('#property-domain-server').on( 'ADD_ROW REMOVE_ROW', updateAmazonCB )
                updateAmazonCB()
        processParsley: ( event ) ->
            $( event.currentTarget )
            .find( 'input' )
            .last()
            .removeClass( 'parsley-validated' )
            .removeClass( 'parsley-error' )
            .next( '.parsley-error-list' )
            .remove()
            $(".parsley-error-list").remove()
        doAction: (action, checked)->
            @[action] and @[action](@validate(action),checked)
        create: (invalid, checked)->
            if not invalid
                domainNameServers = mapFilterInput "#property-domain-server .input"
                if $("#property-amazon-dns").is(":checked")
                    domainNameServers.push("AmazonProvidedDNS")
                data =
                    "domain-name"           : mapFilterInput "#property-dhcp-domain .input"
                    "domain-name-servers"   : domainNameServers
                    "ntp-servers"           : mapFilterInput "#property-ntp-server .input"
                    "netbios-name-servers"  : mapFilterInput "#property-netbios-server .input"
                    "netbios-node-type"     : [parseInt( $("#property-netbios-type .selection").html(), 10 ) || 0]
                validate = (value, key)->
                    if key is 'netbios-node-type'
                        return false
                    if value.length < 1
                        return false
                    else
                        return true
                if not _.some data, validate
                    notification 'error', "You should fill at least one blank."
                    return false
                if data['netbios-node-type'][0] is 0 then data['netbios-node-type'] = []
                @switchAction 'processing'
                afterCreated = @afterCreated.bind @
                @collection.create(data).save().then afterCreated,afterCreated

        delete: (invalid, checked)->
            that = @
            deleteCount += checked.length
            @switchAction 'processing'
            afterDeleted = that.afterDeleted.bind that
            _.each checked, (data)=>
                @collection.findWhere(id: data.data.id).destroy().then afterDeleted, afterDeleted

        afterDeleted: (result)->
            deleteCount--
            if result.error
                deleteErrorCount++
            if deleteCount is 0
                if deleteErrorCount > 0
                    notification 'error', deleteErrorCount+" DhcpOptions failed to delete because of: \"#{result.awsResult}\""
                else
                    notification 'info', "Delete Successfully"
                deleteErrorCount = 0
                @manager.cancel()
        afterCreated: (result)->
            @manager.cancel()
            if result.error
                notification 'error', "Create failed because of: "+result.awsResult
                return false
            notification 'info', "New DHCP Option is created successfully"

        validate: (action)->
            switch action
                when 'create'
                    #@manager.$el.find('input').parsley 'validate'
                    return @manager.$el.find(".parsley-error").size()>0

        switchAction: ( state ) ->
            if not state
                state = 'init'

            @M$( '.slidebox .action' ).each () ->
                if $(@).hasClass state
                    $(@).show()
                else
                    $(@).hide()
        onChangeAmazonDns : ->
            useAmazonDns = $("#property-amazon-dns").is(":checked")
            allowRows    = if useAmazonDns then 3 else 4
            $inputbox    = $("#property-domain-server").attr( "data-max-row", allowRows )
            $rows        = $inputbox.children()
            $inputbox.toggleClass "max", $rows.length >= allowRows
            null

        onChangeDhcpOptions : ( event ) ->
            if event and not $( event.currentTarget ).closest( '[data-bind=true]' ).parsley( 'validate' )
                return

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
                    width: "200px" # or 40%
                    name: 'Name'
                }
                {
                    sortable: false
                    width: "480px" # or 40%
                    name: 'Options'
                }
                {
                    sortable: false
                    width: "56px"
                    name: "Details"
                }
            ]

    dhcpView