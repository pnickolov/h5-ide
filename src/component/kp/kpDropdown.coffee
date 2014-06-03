define [ 'Design', 'kp_manage', './component/kp/kpModel', 'combo_dropdown', './component/kp/kpTpl', 'backbone', 'jquery', 'constant',  'i18n!nls/lang.js' ], ( Design, kpManage, kpModel, comboDropdown, template, Backbone, $, constant, lang ) ->

    Backbone.View.extend {

        showCredential: ->
            App.showSettings App.showSettings.TAB.Credential

        filter: ( keyword ) ->
            hitKeys = _.filter @model.get( 'keys' ), ( k ) ->
                k.keyName.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
            if keyword
                @renderKeys hitKeys
            else
                @renderKeys()

        setKey: ( name, data ) ->
            if @__mode is 'runtime'
                KpModel = Design.modelClassForType( constant.RESTYPE.KP )
                if name is '@no'
                    KpModel.setDefaultKP '', ''
                else
                    KpModel.setDefaultKP name, data.fingerprint
            else
                if name is '@default'
                    @model.setKey '', true
                else if name is '@no'
                    @model.setKey ''
                else
                    @model.setKey name

        manageKp: ( event ) ->
            @renderModal()
            false

        initDropdown: ->
            options =
                manageBtnValue      : lang.ide.PROP_INSTANCE_MANAGE_KP
                filterPlaceHolder   : lang.ide.PROP_INSTANCE_FILTER_KP

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manageKp, @
            @dropdown.on 'change', @setKey, @
            @dropdown.on 'filter', @filter, @


        initialize: ( options ) ->
            @model = new kpModel resModel: ( if options then options.resModel else null )
            @model.on 'change:keys', @renderKeys, @
            @model.on 'request:error', @syncErrorHandler, @

            if not @model.resModel
                @__mode = 'runtime'

            @initDropdown()

        show: () ->
            if App.user.hasCredential()
                if not @model.haveGot()
                    @model.getKeys()
            else
                @renderNoCredential()

        render: ->
            @renderDropdown()
            @el = @dropdown.el
            @


        renderNoCredential: () ->
            @dropdown.render('nocredential').toggleControls false

        syncErrorHandler: (err) ->
            console.error err

        renderKeys: ( data ) ->
            if data and arguments.length is 1
                data =  keys: data, hideDefaultNoKey: true
            else
                data = keys: @model.get('keys')

            if @model.resModel
                if @model.resModel.isNoKey()
                    data.noKey = true
                if @model.resModel.isDefaultKey()
                    data.defaultKey = true

            data.isRunTime = @__mode is 'runtime'

            @dropdown.setContent template.keys data
            @dropdown.toggleControls true
            @

        renderDropdown: () ->
            data = @model.toJSON()
            if data.keyName is '$DefaultKeyPair'
                data.defaultKey = true
            else if data.keyName is 'No Key Pair'
                data.noKey = true

            data.isRunTime = @__mode is 'runtime'

            selection = template.selection data
            @dropdown.setSelection selection


        renderModal: () ->
            new kpManage(model: @model).render()

        }, {

        hasResourceWithDefaultKp: ->
            has = false
            Design.instance().eachComponent ( comp ) ->
                if comp.type in [ constant.RESTYPE.INSTANCE, constant.RESTYPE.LC ]
                    if comp.isDefaultKey() and not comp.get( 'appId' )
                        has = true
                        false

            has
        }





