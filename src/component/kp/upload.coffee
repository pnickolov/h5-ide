define [ './component/kp/template_modal', 'backbone', 'jquery' ], ( template_modal, Backbone, $ ) ->

    Backbone.View.extend

        __data: null


        events:
            'paste .upload-kp-component'                       : 'onPaste'
            'change .upload-kp-component'   : 'hanldeFile'
            'drop .upload-kp-component'     : 'hanldeFile'
            'dragenter .upload-kp-component': 'addDragoverClass'
            'dragleave .upload-kp-component': 'removeDragoverClass'
            'dragover .upload-kp-component' : 'dragoverHandler'


        removeDragoverClass: ( event ) ->
            $( event.currentTarget ).removeClass 'dragover'

        addDragoverClass: ( event ) ->
            $( event.currentTarget ).addClass 'dragover'

        dragoverHandler: ( event) ->
            dt = event.originalEvent.dataTransfer
            if dt then dt.dropEffect = "copy"
            event.stopPropagation()
            event.preventDefault()
            null

        save: ( data ) ->
            if not data then return

            @__data = data
            @$( '#modal-import-json-dropzone' ).addClass 'filled'
            @$( '.key-content' ).text data
            @trigger 'load', data


        onPaste: ( event ) ->
            pasteData = event.originalEvent.clipboardData.getData('text/plain')
            @save pasteData

        hanldeFile: ( evt )->
            evt.stopPropagation()
            evt.preventDefault()

            @$("#modal-import-json-dropzone").removeClass("dragover")
            @$("#import-json-error").html("")

            evt = evt.originalEvent
            files = (evt.dataTransfer || evt.target).files
            if not files or not files.length then return
            @__reader.readAsText( files[0] )
            null

        initialize: ( options ) ->
            that = @
            that.type = options and options.type or 'public key'

            reader = @__reader = new FileReader()

            reader.onload = ( evt )->
                that.save reader.result
                null

            reader.onerror = ()->
                that.trigger 'error'
                null

        getData: ->
            @__data

        render: () ->
            data = type: @type
            @$el.html template_modal.upload data
            @








