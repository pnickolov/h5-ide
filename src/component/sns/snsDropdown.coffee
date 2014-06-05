define [ 'constant', 'CloudResources','sns_manage', 'combo_dropdown', './component/sns/snsTpl', 'i18n!nls/lang.js' ], ( constant, CloudResources, snsManage, comboDropdown, template, lang ) ->

    subCol = CloudResources constant.RESTYPE.SUBSCRIPTION, 'us-east-1'
    topicCol = CloudResources constant.RESTYPE.TOPIC, 'us-east-1'

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            region = Design.instance().region()
            @subCol = CloudResources constant.RESTYPE.SUBSCRIPTION, region
            @topicCol = CloudResources constant.RESTYPE.TOPIC, region
            @topicCol.on 'update', @processCol, @
            @topicCol.on 'change', @processCol, @
            @subCol.on 'update', @processCol, @

        initDropdown: ->
            options =
                manageBtnValue      : lang.ide.PROP_INSTANCE_MANAGE_SNS
                filterPlaceHolder   : lang.ide.PROP_INSTANCE_FILTER_SNS
                classList           : 'sns-dropdown'

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manage, @
            @dropdown.on 'change', @set, @
            @dropdown.on 'filter', @filter, @
            @dropdown.on 'quick_create', @quickCreate, @


        initialize: ( options ) ->
            if options and options.selection
                @selection = options.selection
            @initCol()
            @initDropdown()
            if App.user.hasCredential()
                @topicCol.fetch()
                @subCol.fetch()

        render: ( needInit ) ->
            selection = @selection
            if needInit
                if @topicCol.first()
                    @selection = selection = @topicCol.first().get( 'Name' )
                    @processCol()
                    @trigger 'change', @topicCol.first().id, selection
                else
                    selection = template.dropdown_no_selection()
            else
                if not selection
                    selection = template.dropdown_no_selection()

            @dropdown.setSelection selection
            @el = @dropdown.el
            @

        quickCreate: ->
            new snsManage().render().quickCreate()

        processCol: ( filter, keyword ) ->
            that = @
            if @topicCol.isReady() and @subCol.isReady()
                data = @topicCol.map ( tModel ) ->
                    tData = tModel.toJSON()
                    sub = that.subCol.where TopicArn: tData.id
                    tData.sub = sub.map ( sModel ) -> sModel.toJSON()
                    tData.subCount = tData.sub.length
                    tData

                if filter
                    len = keyword.length
                    data = _.filter data, ( d ) ->
                        d.Name.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1

                selection = @selection
                _.each data, ( d ) ->
                    if d.Name and d.Name is selection
                        d.selected = true
                        null

                @renderDropdownList data

            false


        renderDropdownList: ( data ) ->
            if _.isEmpty data
                region = Design.instance().region()
                regionName = constant.REGION_SHORT_LABEL[ region ]
                @dropdown
                    .setContent( template.nosns regionName: regionName )
                    .toggleControls( true, 'manage')
                    .toggleControls( false, 'filter' )
            else
                @dropdown.setContent( template.dropdown_list data ).toggleControls true

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->
            if App.user.hasCredential()
                @topicCol.fetch()
                @subCol.fetch()
                if not @dropdown.$( '.item' ).length
                    @processCol()
            else
                @renderNoCredential()

        manage: ->
            new snsManage().render()

        set: ( id, data ) ->
            @trigger 'change', id, data.name

        filter: ( keyword ) ->
            @processCol( true, keyword )




