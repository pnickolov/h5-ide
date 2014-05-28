define ["CloudResources", 'constant','combo_dropdown', 'UI.modalplus', 'toolbar_modal', 'i18n!nls/lang.js', './dhcp_template.js'], ( CloudResources, constant, comboDropdown, modalPlus, toolbarModal, lang, template )->
    fetched = false
    dhcpView = Backbone.View.extend
        constructor:->
            @collection = CloudResources constant.RESTYPE.DHCP, Design.instance().region()
            @listenTo @collection, 'change', @render
            @listenTo @collection, 'update', @render
            @listenTo @collection, 'change', @renderManager
            @listenTo @collection, 'change', @renderManager
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
        render: ->
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
        renderDropdown: ->
            data = @collection.toJSON()
            content = template.keys
                isRuntime: false
                keys: data
            @dropdown.toggleControls true
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
            @manager = new toolbarModal @getModalOptions()
            @manager.on 'refresh', @refreshManager, @
            @manager.on 'slidedown', @renderSlides, @
            @manager.on 'action', @doAction, @
            @manager.on 'close', =>
                @manager.remove()
            @manager.render()
            @renderManager()
            @.trigger 'manage'
        refreshManager: ->
            fetched = false
            @renderManager()
        renderManager: ->
            if not fetched
                fetched = true
                @collection.fetchForce().then =>
                    @renderManager()
                return false
            content = template.content items:@collection.toJSON()
            @manager.setContent content

        renderSlides: (which, checked)->
            tpl = template['slide_'+ which]
            slides = @getSlides()
            slides[which]?.call @, tpl, checked
        getSlides: ->
            "delete": (tpl, checked)->
                checkedAmount = checked.length
                if not checkedAmount
                    return
                data = {}

                if checkedAmount is 1
                    data.selectedId = checked[0].data['id']
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
                @manager.$el.find('#create-new-dhcp').on 'OPTION_CHANGE REMOVE_ROW', (e)=>@onChangeDhcpOptions(e)
        processParsley: ( event ) ->
            console.log 'Triggerd ProcessParsley'
            $( event.currentTarget )
            .find( 'input' )
            .last()
            .removeClass( 'parsley-validated' )
            .removeClass( 'parsley-error' )
            .next( '.parsley-error-list' )
            .remove()
        onChangeAmazonDns : ->
            useAmazonDns = $("#property-amazon-dns").is(":checked")
            allowRows    = if useAmazonDns then 3 else 4
            $inputbox    = $("#property-domain-server").attr( "data-max-row", allowRows )
            $rows        = $inputbox.children()
            $inputbox.toggleClass "max", $rows.length >= allowRows

            #@model.setAmazonDns useAmazonDns
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
                    width: "30%" # or 40%
                    name: 'Name'
                }
                {
                    sortable: true
                    width: "60%" # or 40%
                    name: 'Domain-name'
                }
            ]

    dhcpView