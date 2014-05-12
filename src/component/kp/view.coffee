define [ './template', './template_modal', 'backbone', 'jquery', 'constant', 'UI.notification' ], ( template, template_modal, Backbone, $, constant ) ->
    modalView = Backbone.View.extend
        __needDownload: false
        __import: ''

        needDownload: () ->
            if arguments.length is 1
                @__needDownload = arguments[ 0 ]
                if arguments[ 0 ] is false
                    @$( '.cancel' ).prop 'disabled', false
            else
                if @__needDownload then notification 'warning', 'You must download the keypair.'

            @__needDownload

        initialize: () ->
            @model.on 'change:keys', () ->
                if @$( '.scroll-content' ).length
                    @renderKeys()
                else
                    @render true
            , @

        render: ( refresh ) ->
            data = @model.toJSON()
            region = Design.instance().get('region')
            data.regionName = constant.REGION_SHORT_LABEL[ region ]
            @$el.html template_modal.frame data
            if not refresh
                @open()
            @

        renderKeys: () ->
            @$( '.scroll-content tbody' ).html template_modal.keys @model.toJSON()
            @

        renderLoading: () ->
            @$( '.content-wrap' ).html template_modal.loading
            @

        stopPropagation: ( event ) ->
            exception = '.sortable, #download-kp'
            if not $(event.target).is( exception )
                event.stopPropagation()

        open: () ->
            modal @el
            $( '#modal-wrap' ).click @stopPropagation

        showErr: (msg) ->
            @$( '.error' ).text( msg ).show()

        hideErr: () ->
            @$( '.error' ).hide()

        events:
            'click .modal-close' : 'close'
            'change #kp-select-all': 'checkAll'
            'change .one-cb': 'checkOne'

            # actions
            'click #create-kp': 'renderCreate'
            'click #kp-import': 'renderImport'
            'click #kp-delete': 'renderDelete'
            'click #kp-refresh': 'refresh'

            # do action
            'click .do-action': 'doAction'
            'click .cancel': 'cancel'

        doAction: ( event ) ->
            @hideErr()
            action = $( event.currentTarget ).data 'action'
            @[action] and @[action](@validate(action))

        validate: ( action ) ->
            switch action
                when 'create'
                    return not @$( '#create-kp-name' ).parsley 'validate'
                when 'import'
                    return not @$( '#import-kp-name' ).parsley 'validate'


        switchAction: ( state ) ->
            if not state
                state = 'init'

            @$( '.slidebox .action' ).each () ->
                if $(@).hasClass state
                    $(@).show()
                else
                    $(@).hide()

        genDownload: ( key, name ) ->
            base64Key = btoa key
            @$( '#download-kp' )
                .prop( 'href', "data://text/plain;base64,#{base64Key}" )
                .prop( 'download', "#{name}.pem" )

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
                keyName = @$( '#create-kp-name' ).val()
                @switchAction 'processing'
                @model.create( keyName )
                    .then (res) ->
                        console.log res
                        that.needDownload true
                        that.genDownload res.keyMaterial, res.keyName
                        that.switchAction 'download'

                    .catch ( err ) ->
                        console.log(err)
                        that.showErr err.error_message
                        that.switchAction()

        download: () ->
            @needDownload false
            true

        delete: ( invalid ) ->
            $checked = @$('.one-cb:checked')
            count = $checked.length

            onDeleteFinish = @genDeleteFinish count
            @switchAction 'processing'
            that = @
            $checked.each () ->
                that.model.remove( $(@).data 'name' ).then onDeleteFinish, onDeleteFinish

        import: ( invalid ) ->
            that = @
            if not invalid
                keyName = @$( '#import-kp-name' ).val()
                @switchAction 'processing'
                @model.import( keyName, btoa that.__import )
                    .then (res) ->
                        console.log res
                        notification 'info', "#{keyName} is imported."
                        that.cancel()

                    .catch ( err ) ->
                        console.log(err)
                        that.showErr err.error_message
                        that.switchAction 'ready'

        cancel: ->
            @preSlide()

        refresh: ->
            if not @needDownload()
                @model.getKeys()
                @renderLoading()


        renderSlide: ( html ) ->
            @$( '.slidebox .content' ).html html
            @hideErr()

            @

        # if the type need rendered return true
        # or return false
        preSlide: ( type ) ->
            if @needDownload()
                return false

            $content = @$( '.content-wrap' )
            $slidebox = @$( '.slidebox' )
            currentType = $content.hasClass "show-#{type}"

            # Disable checkbox on deleting mode
            if type is 'delete' and not currentType
                @$( 'input[type=checkbox]' ).prop 'disabled', true
            else
                @$( 'input[type=checkbox]' ).prop 'disabled', false


            if not currentType
                $content.removeClass( 'show-create show-import show-delete' )
                if type
                    $content.addClass( "show-#{type}" )
                    $slidebox.addClass 'show'
                else
                    $slidebox.removeClass 'show'
            else
                $content.removeClass( 'show-create show-import show-delete' )
                $slidebox.removeClass 'show' # for transition effective

            not currentType

        renderCreate: () ->
            if @preSlide 'create'
                tpl = template_modal.slideCreate

                data = {}
                html = tpl data
                @renderSlide html

        renderDelete: () ->
            $checked = @$('.one-cb:checked')
            checkedAmount = $checked.length

            if not checkedAmount
                return
            if @preSlide 'delete'
                tpl = template_modal.slideDelete

                data = {}

                if checkedAmount is 1
                    data.selecteKeyName = $checked.data 'name'
                else
                    data.selectedCount = checkedAmount


                html = tpl data
                @renderSlide html

        renderImport: () ->
            if @preSlide 'import'
                tpl = template_modal.slideImport

                data = {}
                html = tpl data
                @renderSlide html
                @preImport()


        preImport: () ->
            that = @
            reader = new FileReader()
            that.__import = ''


            @$( '#modal-import-json-dropzone' )
                .off( 'paste' )
                .on 'paste', ( event ) ->
                    pasteData = event.originalEvent.clipboardData.getData('text/plain')
                    if pasteData
                        that.afterImport pasteData

            reader.onload = ( evt )->
                that.afterImport reader.result
                null

            reader.onerror = ()->
                that.$("#import-json-error").html lang.ide.POP_IMPORT_ERROR
                null

            hanldeFile = ( evt )->
                evt.stopPropagation()
                evt.preventDefault()

                that.$("#modal-import-json-dropzone").removeClass("dragover")
                that.$("#import-json-error").html("")

                evt = evt.originalEvent
                files = (evt.dataTransfer || evt.target).files
                if not files or not files.length then return
                reader.readAsText( files[0] )
                null

            @$("#modal-import-json-file").on "change", hanldeFile
            zone = @$("#modal-import-json-dropzone").on "drop", hanldeFile
            zone.on "dragenter", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", true)
            zone.on "dragleave", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", false)
            zone.on "dragover", ( evt )->
                dt = evt.originalEvent.dataTransfer
                if dt then dt.dropEffect = "copy"
                evt.stopPropagation()
                evt.preventDefault()
                null
            null

        afterImport: ( result ) ->
            @__import = result
            @$( '#modal-import-json-dropzone' ).addClass 'filled'
            @$( '.key-content' ).text result

            @switchAction 'ready'




        checkOne: ( event ) ->
            if event.currentTarget.id isnt 'kp-select-all'
                cbAll = @$ '#kp-select-all'
                cbAmount = @model.get( 'keys' ).length
                checkedAmount = @$('.one-cb:checked').length
                if checkedAmount is cbAmount
                    cbAll.prop 'checked', true
                else if cbAmount - checkedAmount is 1
                    cbAll.prop 'checked', false


        checkAll: ( event ) ->
            if event.currentTarget.checked
                @$('input[type="checkbox"]').prop 'checked', true
            else
                @$('input[type="checkbox"]').prop 'checked', false


        close: ( event ) ->
            if @needDownload()
                return false
            $( '#modal-wrap' ).off 'click', @stopPropagation
            modal.close()
            @remove()
            false

    Backbone.View.extend

        tagName: 'section'

        events:
            'click #keypair-filter'     : 'returnFalse'
            'click .manage-kp'          : 'manageKp'
            'OPTION_SHOW .selectbox'    : 'show'
            'OPTION_CHANGE .selectbox'  : 'setKey'

        setKey: ( event, name ) ->
            if name is '@default'
                @model.setKey ''
            else if name is '@no'
                @model.setKey '', true
            else
                @model.setKey name

        returnFalse: ( event ) ->
            false

        manageKp: ( event ) ->
            @renderModal()
            false

        initialize: ( options ) ->
            @model.on 'change:keys', @renderKeys, @
            @model.on 'request:error', @syncErrorHandler, @

        show: () ->
            if not @model.haveGot()
                @model.getKeys()


        render: () ->
            @renderFrame()
            @

        syncErrorHandler: () ->
            #@renderEmptyKey()


        renderKeys: () ->
            keys = @model.get('keys')
            data = keys: @model.get('keys')

            if @model.resModel.isNoKey()
                data.noKey = true
            if @model.resModel.isDefaultKey()
                data.defaultKey = true

            @$('#kp-list').html template.keys data
            @showManageBtn()
            @

        renderFrame: () ->
            data = @model.toJSON()
            if data.keyName is '$DefaultKeyPair'
                data.defaultKey = true
            else if data.keyName is 'No Key Pair'
                data.noKey = true

            @$el.html template.frame data

        renderModal: () ->
            new modalView(model: @model).render()

        showManageBtn: ->
            @$( '.manage-kp' ).show()






