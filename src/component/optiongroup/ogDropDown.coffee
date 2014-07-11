define [ 'constant', 'CloudResources', 'combo_dropdown', 'og_manage', './component/optiongroup/ogTpl', 'i18n!/nls/lang.js' ], ( constant, CloudResources, comboDropdown, OgManage, template, lang ) ->

    Backbone.View.extend

        tagName: 'section'

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

        render: (option) ->

            @el = @dropdown.el
            @dropdown.setSelection 'None'

            @engine = option.engine
            @version = option.version

            @ogCol = CloudResources(constant.RESTYPE.DBOG, Design.instance().region())
            
            # filter only have engine, version, default option group
            @ogDefaultCol = @ogCol.filter (model, idx) ->
                if model.get('EngineName') is option.engine and
                    model.get('MajorEngineVersion') is option.version and
                        model.get('OptionGroupName').indexOf('default:') is 0
                            return true
                return false

            @renderDropdownList()

            null

            @

        renderDropdownList: () ->

            if @ogDefaultCol.length
                selection = @dropdown.getSelection()
                ogAry = []
                _.each @ogDefaultCol, (og) ->
                    ogData = og.toJSON()
                    ogName = ogData.OptionGroupName
                    if ogName and ogName is selection
                        ogData.selected = true
                    ogAry.push(ogData)
                    null
                @dropdown.setContent(template.dropdown_list ogAry).toggleControls true
            else
                @dropdown.setContent(template.no_option_group({})).toggleControls true

        quickCreate: () ->

            DBOGModel = Design.modelClassForType(constant.RESTYPE.DBOG)
            dbOGModel = new DBOGModel()

            new OgManage({
                engine: @engine,
                version: @version,
                model: dbOGModel
            }).render()

        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        show: ->

            if App.user.hasCredential()
                @renderDropdownList()
            else
                @renderNoCredential()

        manage: ->

            @quickCreate()

        set: ( id, data ) ->

        filter: (keyword) ->