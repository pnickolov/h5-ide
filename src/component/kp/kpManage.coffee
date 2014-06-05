define [ 'toolbar_modal', './component/kp/kpModel', './component/kp/kpDialogTpl', 'kp_upload', 'backbone', 'jquery', 'constant', 'component/exporter/JsonExporter', 'i18n!nls/lang.js', 'UI.notification' ], ( toolbar_modal, kpModel, template, upload, Backbone, $, constant, JsonExporter, lang ) ->

    download = JsonExporter.download

    Backbone.View.extend
        __needDownload: false
        __upload: null
        __import: ''
        __mode: 'normal'

        needDownload: () ->
            if arguments.length is 1
                @__needDownload = arguments[ 0 ]
                if arguments[ 0 ] is false
                    @M$( '.cancel' ).prop 'disabled', false
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
                    width: "40%" # or 40%
                    name: 'Name'
                }
                {
                    sortable: false
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


        initialize: ( options ) ->
            options = {} if not options
            @model = options.model or new kpModel( resModel: options.resModel )

            if App.user.hasCredential()
                if not @model.haveGot()
                    @model.getKeys()

            @initModal()
            @model.on 'change:keys', @renderKeys, @

        render: ( refresh ) ->
            @modal.render()

            if App.user.hasCredential()
                if @model.haveGot()
                    @renderKeys()
            else
                @modal.render 'nocredential'
            @

        renderKeys: () ->
            data = @model.toJSON()
            @modal.setContent template.keys data

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
                    return not @M$( '#create-kp-name' ).parsley 'validate'
                when 'import'
                    return not @M$( '#import-kp-name' ).parsley 'validate'


        switchAction: ( state ) ->
            if not state
                state = 'init'

            @M$( '.slidebox .action' ).each () ->
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

                if not that.model.get( 'keys' ).length
                    that.M$( '#t-m-select-all' )
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
                keyName = @M$( '#create-kp-name' ).val()
                @switchAction 'processing'
                @model.create( keyName )
                    .then (res) ->
                        console.log res
                        that.needDownload true
                        that.genDownload "#{res.keyName}.pem", res.keyMaterial
                        that.switchAction 'download'
                        that.M$( '.before-create' ).hide()
                        that.M$( '.after-create' ).find( 'span' ).text( res.keyName ).end().show()

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
                that.model.remove( c.data.name ).then onDeleteFinish, onDeleteFinish

        import: ( invalid ) ->
            that = @
            if not invalid
                keyName = @M$( '#import-kp-name' ).val()
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
            @model.getKeys()

        renderSlides: ( which, checked ) ->
            tpl = template[ "slide_#{which}" ]
            slides = @getSlides()
            slides[ which ]?.call @, tpl, checked


        getSlides: ->
            that = @
            modal = @modal

            create: ( tpl, checked ) ->
                modal.setSlide tpl

            "delete": ( tpl, checked ) ->
                checkedAmount = checked.length

                if not checkedAmount
                    return

                data = {}

                if checkedAmount is 1
                    data.selecteKeyName = checked[ 0 ].data.name
                else
                    data.selectedCount = checkedAmount

                modal.setSlide tpl data

            import: ( tpl, checked ) ->
                modal.setSlide tpl
                that.__upload and that.__upload.remove()
                that.__upload = new upload()
                that.__upload.on 'load', that.afterImport, @
                that.M$( '.import-zone' ).html that.__upload.render().el


        afterImport: ( result ) ->
            @switchAction 'ready'


