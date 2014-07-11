define [ 'constant', 'CloudResources', 'combo_dropdown', 'og_manage', './component/optiongroup/ogTpl', 'i18n!/nls/lang.js' ], ( constant, CloudResources, comboDropdown, OgManage, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

        initCol: ->
            # @sslCertCol = CloudResources constant.RESTYPE.IAM
            # @sslCertCol.on 'update', @processCol, @
            @processCol()

        initDropdown: ->

            options =
                manageBtnValue      : 'Create New Option Group ...'
                filterPlaceHolder   : 'Filter by Option Group name'

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manage, @
            @dropdown.on 'change', @set, @
            @dropdown.on 'filter', @filter, @
            @dropdown.on 'quick_create', @quickCreate, @

        initialize: () ->

            @initDropdown()
            @initCol()

        quickCreate: () ->

            new OgManage({
                engine: @engine,
                version: @version
            }).render().quickCreate()

        render: ->

            selectionName = @sslCertName or 'None'

            @el = @dropdown.el

            if selectionName is 'None'
                $(@el).addClass('empty')
                # @sslCertCol.fetch()

            @dropdown.setSelection selectionName

            # @setDefault()

            @

        setDefault: ->

            if @sslCertCol.isReady()

                data = @sslCertCol.toJSON()
                if data and data[0] and @uid
                    if @dropdown.getSelection() is 'None'

                        compModel = Design.instance().component(@uid)

                        if compModel

                            listenerAry = compModel.get('listeners')
                            currentListenerObj = listenerAry[@listenerNum]
                            if currentListenerObj and currentListenerObj.protocol in ['HTTPS', 'SSL']

                                compModel.setSSLCert(@listenerNum, data[0].id)
                                @dropdown.trigger 'change', data[0].id
                                @dropdown.setSelection data[0].Name
                                $(@el).removeClass('empty')

        processCol: ( filter, keyword ) ->

            # if @sslCertCol.isReady()

            #     data = @sslCertCol.toJSON()
            #     @setDefault()

            #     if filter
            #         len = keyword.length
            #         data = _.filter data, ( d ) ->
            #             d.Name.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1

            #     @renderDropdownList data

            # false

            @renderDropdownList {}

        renderDropdownList: ( data ) ->

            if data.length
                selection = @dropdown.getSelection()
                _.each data, ( d ) ->
                    if d.Name and d.Name is selection
                        d.selected = true
                    null
                @dropdown.setContent(template.dropdown_list data).toggleControls true
            else
                @dropdown.setContent(template.no_option_group({})).toggleControls true

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->
            # Close Parameter Group Dropdown
            $('#property-dbinstance-parameter-group-select .selectbox').removeClass 'open'
            if App.user.hasCredential()
                # @sslCertCol.fetch()
                @processCol()
            else
                @renderNoCredential()

        setEngine: (engine, version) ->

            @engine = engine
            @version = version
            null

        manage: ->

            new OgManage({
                engine: @engine,
                version: @version
            }).render()

        set: ( id, data ) ->

            # if @uid and id

            #     listenerAry = Design.instance().component(@uid).get('listeners')
            #     currentListenerObj = listenerAry[@listenerNum]
            #     if currentListenerObj and currentListenerObj.protocol in ['HTTPS', 'SSL']
            #         Design.instance().component(@uid).setSSLCert(@listenerNum, id)

        filter: (keyword) ->
            @processCol( true, keyword )
