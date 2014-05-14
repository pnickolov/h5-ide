define [ './template_modal', 'backbone', 'jquery' ], ( template_modal, Backbone, $ ) ->

    Backbone.View.extend

        __data: null


        events:
            'paste *'     : 'returnFalse'
            'click .manage-kp'          : 'manageKp'
            'OPTION_SHOW .selectbox'    : 'show'
            'OPTION_CHANGE .selectbox'  : 'setKey'

        save: ( data ) ->
            if not data then return

            @__data = data
            @$( '#modal-import-json-dropzone' ).addClass 'filled'
            @$( '.key-content' ).text result


        onPaste: ( event ) ->
            pasteData = event.originalEvent.clipboardData.getData('text/plain')
            @save pasteData

        initialize: ( options ) ->
            that = @
            that.type = options and options.type or 'public key'

            reader = new FileReader()

            reader.onload = ( evt )->
                that.save reader.result
                null

            reader.onerror = ()->
                that.trigger 'error'
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

        getData: ->


        render: () ->
            data = type: @type
            @$el.html template_modal.upload data
            @








