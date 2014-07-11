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

            that = this

            @el = @dropdown.el
            @dropdown.setSelection 'None'

            @engine = option.engine
            @version = option.version

            @ogCol = CloudResources(constant.RESTYPE.DBOG, Design.instance().region())
            ogComps = Design.modelClassForType(constant.RESTYPE.DBOG).allObjects()
            
            # only show default og from aws and custom og from stack
            defaultOGAry = []
            @ogCol.each (model, idx) ->
                if model.get('EngineName') is option.engine and
                    model.get('MajorEngineVersion') is option.version and
                        model.get('OptionGroupName').indexOf('default:') is 0
                            defaultOGAry.push {
                                id: null,
                                name: model.get('OptionGroupName')
                            }
                return false

            customOGAry = _.map ogComps, (compModel) ->
                return {
                    id: compModel.id,
                    name: compModel.get('name')
                }

            @ogAry = defaultOGAry.concat customOGAry

            @renderDropdownList()

            null

            @

        renderDropdownList: () ->

            that = this
            if @ogAry.length
                selection = @dropdown.getSelection()
                _.each @ogAry, (og) ->
                    ogName = og.name
                    if ogName and ogName is selection
                        og.selected = true
                    null
                @dropdown.setContent(template.dropdown_list @ogAry).toggleControls true
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
            # Close Parameter Group Dropdown when Option Group Dropdown is opening
            $('#property-dbinstance-parameter-group-select .selectbox').removeClass 'open'
            if App.user.hasCredential()
                @renderDropdownList()
            else
                @renderNoCredential()

        manage: ->

            @quickCreate()

        set: ( id, data ) ->

        filter: (keyword) ->
