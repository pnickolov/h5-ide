define [ 'constant', 'CloudResources', 'combo_dropdown', 'og_manage', './component/optiongroup/ogTpl', 'i18n!/nls/lang.js' ], ( constant, CloudResources, comboDropdown, OgManage, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

        events:
            'click .icon-edit' : 'editClicked'

        initDropdown: ->

            options =
                manageBtnValue      : 'Create New Option Group ...'
                filterPlaceHolder   : 'Filter by Option Group name'
                noFilter            : true

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manage, @
            @dropdown.on 'change', @set, @
            @dropdown.on 'filter', @filter, @
            @dropdown.on 'quick_create', @quickCreate, @

        initialize: (option) ->

            @initDropdown()
            @dbInstance = option.dbInstance

        render: (option) ->

            that = this

            @el = @dropdown.el
            @dropdown.setSelection 'None'

            @engine = option.engine
            @engineVersion = option.engineVersion
            @version = option.majorVersion #major version

            @refresh()

            @

        refresh: () ->

            that = this
            regionName = Design.instance().region()
            engineCol  = CloudResources(constant.RESTYPE.DBENGINE, regionName)
            ogComps    = Design.modelClassForType(constant.RESTYPE.DBOG).allObjects()

            # only show default og from aws and custom og from stack
            defaultOGAry = []
            defaultOG = engineCol.getDefaultByNameVersion regionName, @engine, @engineVersion
            if defaultOG and defaultOG.defaultOGName
                defaultOGAry.push {
                    id: null,
                    name: defaultOG.defaultOGName
                }

            customOGAry = []
            _.each ogComps, (compModel) ->
                if compModel.get('engineName') is that.engine and
                    compModel.get('engineVersion') is that.version
                        customOGAry.push({
                            id: compModel.id,
                            name: compModel.get('name'),
                            data: compModel.toJSON()
                        })

            @ogAry = defaultOGAry.concat customOGAry

            @renderDropdownList()

        renderDropdownList: () ->

            that = this
            if @ogAry.length
                selection = @dbInstance.getOptionGroupName()
                _.each @ogAry, (og) ->
                    ogName = og.name
                    ogPreviewAry = []
                    if og.data
                        _.each og.data.options, (option) ->
                            ogPreviewAry.push(option.OptionName)
                        og.preview = ogPreviewAry.join(',')
                    if ogName and ogName is selection
                        og.selected = true
                        that.dropdown.setSelection selection
                    null
                @dropdown.setContent(template.dropdown_list @ogAry).toggleControls true
            else
                @dropdown.setContent(template.no_option_group({})).toggleControls true

        quickCreate: () ->

            DBOGModel = Design.modelClassForType(constant.RESTYPE.DBOG)
            dbOGModel = new DBOGModel({
                engineName: @engine,
                engineVersion: @version
            })

            new OgManage({
                dbInstance: @dbInstance
                engine: @engine,
                version: @version,
                model: dbOGModel,
                dropdown: @,
                isCreate: true
            }).render()

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->
            # Close Parameter Group Dropdown when Option Group Dropdown is opening
            $('#property-dbinstance-parameter-group-select .selectbox').removeClass 'open'
            # render dropdown list only if no item there
            if not @dropdown.$( '.item' ).length then @renderDropdownList()

        manage: -> @quickCreate()

        set: ( id, data ) -> @dbInstance.setOptionGroup data.name

        filter: (keyword) ->

        editClicked: (event) ->

            $item = $(event.currentTarget).parent()
            ogUID = $item.data('id')

            if ogUID

                ogModel = Design.instance().component(ogUID)
                new OgManage({
                    dbInstance: @dbInstance
                    engine: @engine,
                    version: @version,
                    model: ogModel,
                    dropdown: @
                }).render()

            return false

        setSelection: -> @dropdown.setSelection.apply @, arguments

