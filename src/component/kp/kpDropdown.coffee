define [ 'Design', 'kp_manage', 'combo_dropdown', 'component/kp/kpTpl', 'backbone', 'jquery', 'constant',  'i18n!/nls/lang.js', 'CloudResources' ], ( Design, kpManage, comboDropdown, template, Backbone, $, constant, lang, CloudResources ) ->

    regions = {}

    Backbone.View.extend {

        showCredential: ->
            App.showSettings App.showSettings.TAB.Credential

        filter: ( keyword ) ->
            hitKeys = _.filter @getKey(), ( k ) ->
                k.keyName.toLowerCase().indexOf( keyword.toLowerCase() ) isnt -1
            if keyword
                @renderKeys hitKeys
            else
                @renderKeys()

        getKey: ->
          that = this
          json = @collection.toJSON()
          if @resModel
            _.each json, (e)->
              if e.keyName is that.resModel.getKeyName()
                e.selected = true
          json

        setKey: ( name, data ) ->
            if @__mode is 'runtime'
                KpModel = Design.modelClassForType( constant.RESTYPE.KP )
                if name is '@no'
                    KpModel.setDefaultKP '', ''
                else
                    KpModel.setDefaultKP name, data.fingerprint
            else
                if name is '@default'
                    @resModel.setKey '', true
                else if name is '@no'
                    @resModel.setKey ''
                else
                    @resModel.setKey name

        manageKp: ( event ) ->
            @renderModal()
            false

        initDropdown: ->
            options =
                manageBtnValue      : lang.PROP.INSTANCE_MANAGE_KP
                filterPlaceHolder   : lang.PROP.INSTANCE_FILTER_KP

            @dropdown = new comboDropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manageKp, @
            @dropdown.on 'change', @setKey, @
            @dropdown.on 'filter', @filter, @

        initialize: ( options ) ->
            @resModel = if options then options.resModel else null
            @collection = CloudResources(constant.RESTYPE.KP, Design.instance().get("region"))
            @listenTo @collection, 'update', @renderKeys
            @listenTo @collection, 'change', @renderKeys
            if not @resModel
                @__mode = 'runtime'

            @initDropdown()

        show: () ->
            if App.user.hasCredential()
                def = null
                if not regions[Design.instance().get("region")] and @collection.isReady()
                    regions[Design.instance().get("region")] = true
                    def = @collection.fetchForce()
                else
                    regions[Design.instance().get("region")] = true
                    def = @collection.fetch()
                def.then =>
                    @renderKeys()
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
                data = keys: @getKey()

            if @resModel
                if @resModel.isNoKey()
                    data.noKey = true
                if @resModel.isDefaultKey()
                    data.defaultKey = true

            data.isRunTime = @__mode is 'runtime'

            @dropdown.setContent template.keys data
            @dropdown.toggleControls true
            @

        renderDropdown: () ->
            @data =
              keyName: if @resModel then @resModel.getKeyName() else ""
            if @data.keyName is '$DefaultKeyPair'
                @data.defaultKey = true
            else if @data.keyName is 'No Key Pair'
                @data.noKey = true

            @data.isRunTime = @__mode is 'runtime'

            selection = template.selection @data
            @dropdown.setSelection selection

        renderModal: ()->
            that = @
            new kpManage(
                model: that.data
            )

        remove: ->
            @dropdown.remove()
            Backbone.View.prototype.remove.apply @, arguments

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





