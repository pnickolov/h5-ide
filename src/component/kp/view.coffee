define [ './template', './template_modal', 'backbone', 'jquery'], ( template, template_modal, Backbone, $ ) ->
    modalView = Backbone.View.extend

        render: () ->
            @$el.html template_modal()
            @open()
            @

        stopPropagation: ( event ) ->
            exception = '.sortable'
            if not $(event.target).is( exception )
                event.stopPropagation()

        open: () ->
            modal @el, true
            $( '#modal-wrap' ).click @stopPropagation

        events:
            'click .modal-close' : 'close'

        close: ( event ) ->
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
            @model.on 'sync:error', @syncErrorHandler, @

        show: () ->
            if not @model.haveGot()
                @model.getKeys()


        render: () ->
            @renderFrame()
            @

        syncErrorHandler: () ->
            @renderEmptyKey()


        renderKeys: () ->
            keys = @model.get('keys')
            data = keys: @model.get('keys')

            if @model.resModel.isNoKey()
                data.noKey = true
            if @model.resModel.isDefaultKey()
                data.defaultKey = true

            @$('#kp-list').html template.keys data
            @

        renderFrame: () ->
            data = @model.toJSON()
            if data.keyName is '$DefaultKeyPair'
                data.defaultKey = true
            else if data.keyName is 'No Key Pair'
                data.noKey = true

            @$el.html template.frame data

        renderModal: () ->
            new modalView().render()






