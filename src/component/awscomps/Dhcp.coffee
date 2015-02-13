define ["CloudResources", 'constant','combo_dropdown', 'dhcp_manage', 'UI.modalplus', 'toolbar_modal', 'i18n!/nls/lang.js', 'component/awscomps/DhcpTpl'], ( CloudResources, constant, comboDropdown, dhcpManager, modalPlus, toolbarModal, lang, template )->
    fetched = false
    DhcpDropdown = Backbone.View.extend
        constructor:(options)->
            @resModel = options?.resModel
            @collection = CloudResources Design.instance().credentialId(), constant.RESTYPE.DHCP, Design.instance().region()
            @listenTo @collection, 'change', @render
            @listenTo @collection, 'update', @render
            option =
                manageBtnValue: lang.PROP.VPC_MANAGE_DHCP
                filterPlaceHolder: lang.PROP.VPC_FILTER_DHCP
                resourceName: lang.PROP.RESOURCE_NAME_DHCP
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
        initialize: ( options ) -> _.extend @, options
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
            if Design.instance().credential() and not Design.instance().credential().isDemo()
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
            if Design.instance() and (Design.instance().modeIsApp() or Design.instance().modeIsAppEdit())
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

        manageDhcp: ()->
          new dhcpManager().render()

    DhcpDropdown
