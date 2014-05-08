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
        id: 'keypair-select'
        className: 'selectbox'

        events:
            'click #keypair-filter' : 'returnFalse'
            'click .manage-kp'      : 'manageKp'

        returnFalse: ( event ) ->
            false

        manageKp: ( event ) ->
            @renderModal()
            false

        initialize: ( options ) ->

        render: () ->
            @renderFrame()
            @

        renderFrame: () ->
            @$el.html template.frame()

        renderModal: () ->
            new modalView().render()






