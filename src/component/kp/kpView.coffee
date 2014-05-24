define [ 'combo_dropdown', 'toolbar_modal', './kpTpl', './kpDialogTpl', 'kp_upload', 'backbone', 'jquery', 'constant', 'component/exporter/JsonExporter', 'i18n!nls/lang.js', 'UI.notification' ], ( combo_dropdown, toolbar_modal, template, template_modal, upload, Backbone, $, constant, JsonExporter, lang ) ->

    download = JsonExporter.download

    modalView = Backbone.View.extend
        __needDownload: false
        __upload: null
        __import: ''
        __mode: 'normal'

        needDownload: () ->
            if arguments.length is 1
                @__needDownload = arguments[ 0 ]
                if arguments[ 0 ] is false
                    @m$( '.cancel' ).prop 'disabled', false
            else
                if @__needDownload then notification 'warning', 'You must download the keypair.'

            @__needDownload

        denySlide: () ->
            not @needDownload()

        getRegion: ->
            region = Design.instance().get('region')
            constant.REGION_SHORT_LABEL[ region ]

        getModalOptions: ->
            that = @
            region = Design.instance().get('region')
            regionName = constant.REGION_SHORT_LABEL[ region ]

            title: "Manage Key Pairs in #{regionName}"
            slideable: _.bind that.denySlide, that
            context: that
            buttons: [
                {
                    icon: 'new-stack'
                    type: 'create'
                    name: 'Create Key Pair'
                }
                {
                    icon: 'import'
                    type: 'import'
                    name: 'Import Key Pair'
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
                    width: "100px" # or 40%
                    name: 'Name'
                }
                {
                    sortable: false
                    width: "100px" # or 40%
                    name: 'Fingerprint'
                }
            ]

        initModal: () ->
            new toolbar_modal @getModalOptions()
            @modal.on 'close', () ->
                @remove()
            , @

            @modal.on 'slidedown', @renderSlides, @
            @modal.on 'action', @doAction, @
            @modal.on 'refresh', @refresh, @


        initialize: () ->
            @initModal()
            @model.on 'change:keys', @renderKeys, @

        renderModal: () ->
            @modal.render()
            @renderKeys()
            @

        render: ( refresh ) ->
            @renderModal()
            @

        renderKeys: () ->
            data = @model.toJSON()
            @modal.setContent template_modal.keys data

            @

        __events:

            # actions
            'click #kp-create': 'renderCreate'
            'click #kp-import': 'renderImport'
            'click #kp-delete': 'renderDelete'
            'click #kp-refresh': 'refresh'

            # do action
            #'click .do-action': 'doAction'
            'click .cancel': 'cancel'

        downloadKp: ->
            @__downloadKp and @__downloadKp()

        doAction: ( action, checked ) ->
            @[action] and @[action](@validate(action), checked)

        validate: ( action ) ->
            switch action
                when 'create'
                    return not @m$( '#create-kp-name' ).parsley 'validate'
                when 'import'
                    return not @m$( '#import-kp-name' ).parsley 'validate'


        switchAction: ( state ) ->
            if not state
                state = 'init'

            @m$( '.slidebox .action' ).each () ->
                if $(@).hasClass state
                    $(@).show()
                else
                    $(@).hide()

        genDownload: ( name, str ) ->
            @__downloadKp = ->
                if $("body").hasClass("safari")
                  blob = null
                else
                  blob = new Blob [str]

                if not blob
                  return {
                    data : "data://text/plain;,#{str}"
                    name : name
                  }

                download( blob, name )
                null

            @__downloadKp

        genDeleteFinish: ( times ) ->
            success = []
            error = []
            that = @

            finHandler = _.after times, ->
                that.cancel()
                if success.length is 1
                    notification 'info', "#{success[0].param[4]} is deleted."
                else if success.length > 1
                    notification 'info', "Selected #{success.length} key pairs are deleted."

                that.processDelBtn()

                if not that.model.get( 'keys' ).length
                    that.m$( '#kp-select-all' )
                        .get( 0 )
                        .checked = false

                _.each error, ( s ) ->
                    console.log(s)

            ( res ) ->
                if not res.is_error
                    success.push res
                else
                    error.push res

                finHandler()

        create: ( invalid ) ->
            that = @
            if not invalid
                keyName = @m$( '#create-kp-name' ).val()
                @switchAction 'processing'
                @model.create( keyName )
                    .then (res) ->
                        console.log res
                        that.needDownload true
                        that.genDownload "#{res.keyName}.pem", res.keyMaterial
                        that.switchAction 'download'
                        that.m$( '.before-create' ).hide()
                        that.m$( '.after-create' ).find( 'span' ).text( res.keyName ).end().show()

                    .catch ( err ) ->
                        console.log(err)
                        that.modal.error err.error_message
                        that.switchAction()

        download: () ->
            @needDownload false
            @__downloadKp and @__downloadKp()

        delete: ( invalid, checked ) ->
            count = checked.length

            onDeleteFinish = @genDeleteFinish count
            @switchAction 'processing'
            that = @
            _.each checked, ( c ) ->
                that.model.remove( c.data[ 'name' ] ).then onDeleteFinish, onDeleteFinish

        import: ( invalid ) ->
            that = @
            if not invalid
                keyName = @m$( '#import-kp-name' ).val()
                @switchAction 'processing'
                try
                    keyContent = btoa that.__upload.getData()
                catch
                    @modal.error 'Key is not in valid OpenSSH public key format'
                    that.switchAction 'init'
                    return


                @model.import( keyName, keyContent)
                    .then (res) ->
                        console.log res
                        notification 'info', "#{keyName} is imported."
                        that.cancel()

                    .catch ( err ) ->
                        console.log(err)
                        that.modal.error err.error_message
                        that.switchAction 'ready'

        cancel: ->
            @modal.cancel()

        refresh: ->
            if not @needDownload()
                @model.getKeys()


        renderSlides: ( which, checked ) ->
            tpl = template_modal[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked


        getSlides: ->
            that = @
            modal = @modal
            __upload = @__upload


            create: ( tpl, checked ) ->
                modal.setSlide tpl

            "delete": ( tpl, checked ) ->
                checkedAmount = checked.length

                if not checkedAmount
                    return

                data = {}

                if checkedAmount is 1
                    data.selecteKeyName = checked[ 0 ].data[ 'name' ]
                else
                    data.selectedCount = checkedAmount

                modal.setSlide tpl data

            import: ( tpl, checked ) ->
                modal.setSlide tpl
                that.__upload and that.__upload.remove()
                that.__upload = new upload()
                that.__upload.on 'load', that.afterImport, @
                that.m$( '.import-zone' ).html that.__upload.render().el



        afterImport: ( result ) ->
            @switchAction 'ready'


    # ------ export ------ #

    Backbone.View.extend

        showCredential: ->
            App.showSettings App.showSettings.TAB.Credential

        filter: ( keyword ) ->
            len = keyword.length
            hitKeys = _.filter @model.get( 'keys' ), ( k ) ->
                k.keyName.slice( 0, len ).toLowerCase() is keyword
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

            @dropdown = new combo_dropdown( options )
            @dropdown.on 'open', @show, @
            @dropdown.on 'manage', @manageKp, @
            @dropdown.on 'change', @setKey, @
            @dropdown.on 'filter', @filter, @


        initialize: ( options ) ->
            @model.on 'change:keys', @renderKeys, @
            @model.on 'request:error', @syncErrorHandler, @

            if not @model.resModel
                @__mode = 'runtime'

            @initDropdown()

        show: () ->
            if App.user.hasCredential()
                if not @model.haveGot()
                    @renderLoading()
                    @model.getKeys()
            else
                @renderNoCredential()

        render: ->
            @renderDropdown()
            @el = @dropdown.el
            @

        renderLoading: ->
            @dropdown.render('loading').toggleControls false

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
            new modalView(model: @model).render()





